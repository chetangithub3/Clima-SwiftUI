//
//  ContentView.swift
//  Clima-SwiftUI
//
//  Created by Chetan Dhowlaghar on 8/20/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var contentViewModel = ContentViewModel()
    @State var city = ""
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    contentViewModel.handleLocation()
                } label: {
                    Image(systemName: "location.magnifyingglass")
                }
                
                TextField("City Name", text: $city)
                Button {
                    contentViewModel.getWeatherFromCity(city: city, unit: .metric)
                    city = ""
                } label: {
                    Image(systemName: "magnifyingglass")
                }
            }.padding()
            
            Text(contentViewModel.searchHistory.last?.cityName ?? "")
            Image(systemName: contentViewModel.searchHistory.last?.conditionName ?? "")
            Text(contentViewModel.searchHistory.last?.temperatureString ?? "")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
