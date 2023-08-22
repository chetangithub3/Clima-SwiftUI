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
        List{
            Section{
                ForEach(contentViewModel.searchHistory.reversed()) { item in
                    
                    VStack{
                        Text(item.cityName)
                        Image(item.conditionName)
                        HStack(spacing: 0){
                            Text(item.temperatureString)
                        }
                    }
                }
                
            } header: {
                Text("Search History")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            
        }
    }
    
}


struct SearchHistoryView_Previews: PreviewProvider {

    static var previews: some View {
        SearchHistoryView(showHistory: .constant(true))
    }
}
