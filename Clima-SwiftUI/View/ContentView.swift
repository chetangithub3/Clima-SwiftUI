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
                            .bold()
                           
                    }.padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    
                    TextField("City Name", text: $city)
                        .padding()
                           .background(Color.white)
                           .cornerRadius(10)
                    Button {
                        contentViewModel.getWeatherFromCity(city: city, unit: selectedUnit)
                        city = ""
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .bold()
                            
                    }.padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .alert("Server Error", isPresented: $contentViewModel.showInputErrorAlert) {
                    Button("Ok") {
                        contentViewModel.showServerErrorAlert = false
                    }
                } message: {
                    Text("Error retrieving weather info. Please try again.")
                }
                .alert("Input Error", isPresented: $contentViewModel.showInputErrorAlert) {
                    Button("Ok") {
                        contentViewModel.showInputErrorAlert = false
                    }
                } message: {
                    Text("Please enter a valid city name")
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
                        .bold()
                }.padding()
                    .background(Color.white)
                    .cornerRadius(10)
                
                
            }.padding()
                .navigationTitle("Clima-SwiftUI")
                .background(Color(red: 246/255, green: 244/255, blue: 235/255))
                .onAppear {
                    if let url = lastSearchURL{
                        contentViewModel.fetchData(from: url)
                    }
                }
                .sheet(isPresented: $showHistory, content: {
                    SearchHistoryView(showHistory: $showHistory).environmentObject(contentViewModel)
                })
            
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView( units: "C")
    }
}
