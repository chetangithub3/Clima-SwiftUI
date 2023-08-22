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
    @State var showNoInputAlert = false
    var body: some View {
        NavigationView {
            
            VStack(alignment: .leading) {
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
                        //TODO:
                        // Search for how to add cities with multiple words like new york
                        //currently fails
                        city =  city.trimmingCharacters(in: .whitespacesAndNewlines)
                        if city.isEmpty {
                            showNoInputAlert = true
                            return
                        }
                        contentViewModel.getWeatherFromCity(city: city, unit: selectedUnit)
                        city = ""
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .bold()
                            
                    }.padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .alert("No input", isPresented: $showNoInputAlert) {
                    Button("Ok") {
                        contentViewModel.showServerErrorAlert = false
                    }
                } message: {
                    Text("Please enter a city name")
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
                VStack(alignment: .leading){
                    Picker(selection: $selectedUnit, label: Text("Units:")) {
                        Text("Metric")
                            .tag(Units.metric)
                        Text("Imperial")
                            .tag(Units.imperial)
                    }.pickerStyle(.segmented)
                }.padding(.vertical)
                
                .onChange(of: selectedUnit) { newValue in
                    units = selectedUnit == .imperial ? "°F" : "°C"
                    if lastSearchURL != nil{
                        contentViewModel.getWeatherOnChangeOfUnits(newUnit: newValue)
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
                    
                   
                }
                Spacer()
                Button {
                    showHistory = true
                } label: {
                    HStack{
                        Spacer()
                        Text("Search History")
                            .bold()
                            .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                        Spacer()
                    }
                    
                }
                
                
                
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
