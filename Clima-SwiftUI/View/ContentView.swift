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
    @State var selectedUnit = Units.imperial
    
    @State var units: String = "C"
    var body: some View {
        NavigationView {
            
            VStack {
                HStack {
                    Button {
                        contentViewModel.handleLocation(unit: selectedUnit)
                    } label: {
                        Image(systemName: "location.magnifyingglass")
                    }
                    
                    TextField("City Name", text: $city)
                    Button {
                        contentViewModel.getWeatherFromCity(city: city, unit: selectedUnit)
                        city = ""
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }.padding()
                HStack(alignment: .center, spacing: 20) {
                    VStack{
                        Text(contentViewModel.searchHistory.last?.cityName ?? "")
                        Image(systemName: contentViewModel.searchHistory.last?.conditionName ?? "")
                        HStack{
                            Text(contentViewModel.searchHistory.last?.temperatureString ?? "" )
                        }
                    }
                    
                    VStack{
                        Picker(selection: $selectedUnit, label: Text("Units:")) {
                            Text("Metric").tag(Units.metric)
                            Text("Imperial").tag(Units.imperial)
                        }.pickerStyle(.menu)
                    }
                }
                Spacer()
            }.padding()
            .navigationTitle("Clima-SwiftUI")
                
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView( units: "C")
    }
}
