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
        fetchURLResponse(from: url)
    }
    func getWeatherFromLocation(unit: Units) {
        
    }
    
    func fetchURLResponse(from url: URL) {
        
        URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .tryMap { (data, response) -> Data in
                guard let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
                    throw URLError(URLError.badServerResponse)
                }
                
                return data
                
            }
            .decode(type: WeatherData.self, decoder: JSONDecoder())
            .sink { (completion) in
                switch completion {
                    case .finished:
                        return
                    case .failure(let error):
                        print(error.localizedDescription)
                }
                print("completion - \(completion)")
            } receiveValue: {[weak self] weatherData in
                guard let self = self else {return}
                if let name = weatherData.name, let condition = weatherData.weather?.first?.id, let temp = weatherData.main?.temp {
                    let weatherModel = WeatherModel(cityName: name, conditonID: condition, temperature: Float(temp))
                    self.searchHistory.append(weatherModel)
                }
                
            }.store(in: &cancellebles)
    }
}
