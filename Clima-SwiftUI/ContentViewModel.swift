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

enum Units: String {
    
    case metric = "metric"
    case kelvin = "kelvin"
    case farh = "fahrenheit"
}

class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    var cancellebles = Set<AnyCancellable>()
    private var locationManager = CLLocationManager()
    
    @Published var searchHistory: [WeatherModel] = []
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func handleLocation() {
        let locationStatus = locationManager.authorizationStatus
        switch locationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                let location = locationManager.location
                if let lat = location?.coordinate.latitude, let lon = location?.coordinate.longitude {
                    getWeatherFromLocation(unit: .metric, lat: lat, lon: lon)
                }
                break
            case .denied:
                openAppSettings()
                break
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
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

    
    func getWeatherFromCity(city: String, unit: Units) {
        let baseURL = "https://api.openweathermap.org/data/2.5/weather?appid=04720e6c5a6808a994667a251ec0199a"
        let units = "&units=\(unit.rawValue)"
        let url = baseURL + units + "&q=\(city)"
        print(url)
        guard let url = URL(string: url) else {return}
        fetchData(from: url)
    }
    func getWeatherFromLocation(unit: Units, lat: Double, lon: Double) {
        let baseURL = "https://api.openweathermap.org/data/2.5/weather?appid=04720e6c5a6808a994667a251ec0199a"
        let units = "&units=\(unit.rawValue)"
        let url = baseURL + units + "&lat=\(lat)&lon=\(lon)"
        guard let url = URL(string: url) else {return}
        fetchData(from: url)
    }
    
    func fetchData(from url: URL) {
        
        APIManager.publisher(for: url)
            .sink (receiveCompletion: { (completion) in
                switch completion {
                    case .finished:
                        return
                    case .failure(let error):
                        print(error.localizedDescription)
                }
                print("completion - \(completion)")
            }, receiveValue: { (weatherData: WeatherData) in
                
                if let name = weatherData.name, let condition = weatherData.weather?.first?.id, let temp = weatherData.main?.temp {
                    let weatherModel = WeatherModel(cityName: name, conditonID: condition, temperature: Float(temp))
                    self.searchHistory.append(weatherModel)
                }
                
            })
            .store(in: &cancellebles)
    }
}
