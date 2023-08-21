//
//  ContentView.swift
//  Clima-SwiftUI
//
//  Created by Chetan Dhowlaghar on 8/20/23.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("lastSearchURL") var lastSearchURL: URL?
    @StateObject var contentViewModel = ContentViewModel()
    @State var city = ""
    @State var selectedUnit = Units.imperial
    @State var units: String = ""
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
                        HStack(spacing: 0){
                            Text(contentViewModel.searchHistory.last?.temperatureString ?? "" )
                            Text(units)
                        }
                    }
                    
                    VStack{
                        Picker(selection: $selectedUnit, label: Text("Units:")) {
                            Text("Metric").tag(Units.metric)
                            Text("Imperial").tag(Units.imperial)
                        }.pickerStyle(.menu)
                    }.onChange(of: selectedUnit) { newValue in
                        units = selectedUnit == .imperial ? "°F" : "°C"
                        if lastSearchURL != nil{
                            contentViewModel.getWeatherOnChangeOfUnits(newUnit: newValue)
                        }
                    }
                }
                Spacer()
                NavigationLink {
                    SearchHistoryView().environmentObject(contentViewModel)
                } label: {
                    Text("Search History")
                }

             
            }.padding()
            .navigationTitle("Clima-SwiftUI")
            .onAppear {
                if let url = lastSearchURL{
                    contentViewModel.fetchData(from: url)
                }
            }
                
        }
    }
}

struct SearchHistoryView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    var body: some View {
        List{
            ForEach(contentViewModel.searchHistory.reversed()) { item in
                Section{
                    VStack{
                        Text(item.cityName)
                        Image(item.conditionName)
                        HStack(spacing: 0){
                            Text(item.temperatureString)
                        }
                    }
                }
               
            }
        }.navigationTitle("Search History")
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView( units: "C")
    }
}
