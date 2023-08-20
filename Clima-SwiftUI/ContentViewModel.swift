//
//  ContentViewModel.swift
//  Clima-SwiftUI
//
//  Created by Chetan Dhowlaghar on 8/20/23.
//

import Foundation
import Combine

enum Units: String {
    
    case metric = "metric"
    case kelvin = "kelvin"
    case farh = "fahrenheit"
}

class ContentViewModel: ObservableObject {
    var cancellebles = Set<AnyCancellable>()
    @Published var searchHistory: [WeatherModel] = []
    
    
    
    func getWeatherFromCity(city: String, unit: Units) {
        var baseURL = "https://api.openweathermap.org/data/2.5/weather?appid=04720e6c5a6808a994667a251ec0199a"
        let units = "&units=\(unit.rawValue)"
        let url = baseURL + units + "&q=\(city)"
        print(url)
        guard let url = URL(string: url) else {return}
        fetchData(from: url)
    }
    func getWeatherFromLocation(unit: Units) {
        
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
