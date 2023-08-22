    //
    //  ContentViewModel.swift
    //  Clima-SwiftUI
    //
    //  Created by Chetan Dhowlaghar on 8/20/23.
    //

import Foundation
import Combine
import CoreLocation
import UIKit
import SwiftUI
enum Units: String {
    
    case metric = "metric"
    case imperial = "imperial"
}

class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @AppStorage("lastSearchURL") var lastSearchURL: URL?

    var cancellebles = Set<AnyCancellable>()
    private var locationManager = CLLocationManager()
    var ignoredOnLaunch = false
    @Published var searchHistory: [WeatherModel] = []
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var showInputErrorAlert = false
    @Published var showServerErrorAlert = false
    override init() {
        super.init()
        setupLocationManager()
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func handleLocation(unit: Units) {
        let locationStatus = locationManager.authorizationStatus
        switch locationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                let location = locationManager.location
                if let lat = location?.coordinate.latitude, let lon = location?.coordinate.longitude {
                    getWeatherFromLocation(unit: unit, lat: lat, lon: lon)
                }
                break
            case .denied:
                openAppSettings()
                break
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                openAppSettings()
                break
            default:
                locationManager.requestWhenInUseAuthorization()
                break
        }
    
        
    }
    
    func openAppSettings() {
          if let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/") {
              UIApplication.shared.open(url, options: [:], completionHandler: nil)
          }
      }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if !ignoredOnLaunch {
            ignoredOnLaunch.toggle()
           return
        }
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            let location = locationManager.location
            if let lat = location?.coordinate.latitude, let lon = location?.coordinate.longitude {
                getWeatherFromLocation(unit: .metric, lat: lat, lon: lon)
            }
        }
    }

    
    func getWeatherFromCity(city: String, unit: Units) {
        let baseURL = "https://api.openweathermap.org/data/2.5/weather?appid=04720e6c5a6808a994667a251ec0199a"
        let units = "&units=\(unit.rawValue)"
        let url = baseURL +  "&q=\(city)" + units
        guard let url = URL(string: url) else {return}
        fetchData(from: url)
    }
    func getWeatherFromLocation(unit: Units, lat: Double, lon: Double) {
        let baseURL = "https://api.openweathermap.org/data/2.5/weather?appid=04720e6c5a6808a994667a251ec0199a"
        let units = "&units=\(unit.rawValue)"
        let url = baseURL +  "&lat=\(lat)&lon=\(lon)" + units
        guard let url = URL(string: url) else {return}
        fetchData(from: url)
    }
    
    func getWeatherOnChangeOfUnits(newUnit: Units){
        guard let urlString = lastSearchURL?.absoluteString else { return  }
        let truncated = truncateString(urlString, fromSubstring: "&units=")
        let newURL = truncated + "&units=\(newUnit.rawValue)"
        guard let url = URL(string: newURL) else {return}
        fetchData(from: url)
    }
    
    func truncateString(_ input: String, fromSubstring substring: String) -> String {
           if let range = input.range(of: substring) {
               let truncatedString = input.prefix(upTo: range.lowerBound)
               return String(truncatedString)
           }
           return input
       }
    func fetchData(from url: URL) {
        print("...............\(showInputErrorAlert)")
        APIManager.publisher(for: url)
            .sink (receiveCompletion: { (completion) in
                switch completion {
                    case .finished:
                        return
                    case .failure(let error):
                        print(error.localizedDescription)
                        self.showInputErrorAlert = true
                        
                }
                print("completion - \(completion)")
            }, receiveValue: { (weatherData: WeatherData) in
                
                if let name = weatherData.name, let condition = weatherData.weather?.first?.id, let temp = weatherData.main?.temp {
                    let weatherModel = WeatherModel(cityName: name, conditonID: condition, temperature: Float(temp))
                    self.searchHistory.append(weatherModel)
                    self.lastSearchURL = url
                }
                
            })
            .store(in: &cancellebles)
    }
}
