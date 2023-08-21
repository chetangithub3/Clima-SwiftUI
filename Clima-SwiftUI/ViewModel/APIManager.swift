//
//  APIManager.swift
//  Clima-SwiftUI
//
//  Created by Chetan Dhowlaghar on 8/20/23.
//

import Foundation
import Combine

public struct APIManager {
    
    static func publisher<T: Decodable>(for url: URL) -> AnyPublisher<T, Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) in
                guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
                    throw URLError(URLError.badServerResponse)
                }
                return data               
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
    }
    
}
