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
    @State var showHistory = false
    var body: some View {
        NavigationView {
            
            VStack {
                HStack {
                    Button {
                        contentViewModel.handleLocation(unit: selectedUnit)
                    } label: {
                        Image(systemName: "location.magnifyingglass")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    
                    TextField("City Name", text: $city)
                    Button {
                        contentViewModel.getWeatherFromCity(city: city, unit: selectedUnit)
                        city = ""
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                }
                HStack(alignment: .center, spacing: 20) {
                    VStack{
                        Text(contentViewModel.searchHistory.last?.cityName ?? "")
                        Image(systemName: contentViewModel.searchHistory.last?.conditionName ?? "")
                            .resizable()
                            .frame(width: 100, height: 100)
                        HStack(spacing: 0){
                            Text(contentViewModel.searchHistory.last?.temperatureString ?? "" )
                            
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
                Button {
                    showHistory = true
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
                .sheet(isPresented: $showHistory, content: {
                    SearchHistoryView(showHistory: $showHistory).environmentObject(contentViewModel)
                })
                .alert(isPresented: $contentViewModel.showInputErrorAlert) {
                    Alert(
                        title: Text("Input Error"),
                        message: Text("Please enter a valid city name"),
                        dismissButton: .cancel(Text("Ok"), action: {
                            contentViewModel.showInputErrorAlert = false
                        })
                    )
                }
                .alert(isPresented: $contentViewModel.showServerErrorAlert) {
                    Alert(
                        title: Text("Server Error"),
                        message: Text("Error retrieving weather info. Please try again."),
                        dismissButton: .cancel(Text("Ok"), action: {
                            contentViewModel.showServerErrorAlert = false
                        })
                    )
                }
            
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView( units: "C")
    }
}
