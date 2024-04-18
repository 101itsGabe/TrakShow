//
//  FullUserSearchView.swift
//  TrakShow
//
//  Created by Gabriel Mannheimer on 4/17/24.
//

import SwiftUI

struct FullUserSearchView: View {
    @State private var search: String = ""
    @StateObject var trakShowManager: TrakShowManager
    @State private var curUsers: [String] = []
    var body: some View {
        ZStack{
            VStack{
                HStack(spacing: 10){
                    Image(systemName: "magnifyingglass")
                        .padding(.leading)
                    TextField("", text: $search, prompt: {
                        Text("Search")
                            .foregroundColor(.white)
                    }())
                    .onChange(of: search){ newValue in
                        Task{
                            //await trakShowManager.getShows(search: newValue, page: curPage ?? 1)
                            //await trakShowManager.getMazeShows(search: newValue)
                            //await TrakShowManager.getFollowers()
                        }
                    }
                    
                }
                .foregroundColor(.white)
                .frame(width:350, height: 50)
                .background(trakShowManager.logintxtColor)
                .cornerRadius(20)
                .padding()
                
                List{
                    ForEach(curUsers, id: \.self){username in
                        Text(username)
                            .padding()
                    }
                }
                .scrollContentBackground(.hidden)
                .background(trakShowManager.bkgrColor)
                
                
            }
            .scrollContentBackground(.hidden)
            .background(trakShowManager.bkgrColor)
        }
        .onAppear(){
            //Pull list from firebase
            
        }
    }
}

#Preview {
    FullUserSearchView(trakShowManager: TrakShowManager())
}
