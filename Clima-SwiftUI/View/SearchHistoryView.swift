//
//  SearchHistoryView.swift
//  Clima-SwiftUI
//
//  Created by Chetan Dhowlaghar on 8/21/23.
//

import SwiftUI

struct SearchHistoryView: View {
    @Binding var showHistory: Bool
    @EnvironmentObject var contentViewModel: ContentViewModel
    var body: some View {
        VStack(alignment: .leading){
            Text("Search History")
                .font(.title)
                .fontWeight(.bold)
                .padding()
 
                ForEach(contentViewModel.searchHistory.reversed()) { item in
                    HStack{
                        VStack(alignment: .leading){
                            Text(item.cityName)
                            HStack(spacing: 0){
                                Text(item.temperatureString)
                            }
                        }
                        
                        Spacer()
                        Image(systemName: item.conditionName).resizable()
                            .frame(width: 50, height: 50)
                    }.padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    
                }
            Spacer()
        }.padding()
        .background(Color(red: 246/255, green: 244/255, blue: 235/255))
    }
    
}


struct SearchHistoryView_Previews: PreviewProvider {

    static var previews: some View {
        SearchHistoryView(showHistory: .constant(true))
    }
}
