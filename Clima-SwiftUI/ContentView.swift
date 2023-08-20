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
            TextField("City Name", text: $city)
            Text(contentViewModel.searchHistory.last?.cityName ?? "")
            Text(contentViewModel.searchHistory.last?.conditionName ?? "")
            Text(contentViewModel.searchHistory.last?.temperatureString ?? "")
            
            Button {
                contentViewModel.getWeatherFromCity(city: city, unit: .metric)
            } label: {
                Text("Get Data")
            }

        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
