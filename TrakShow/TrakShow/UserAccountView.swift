//
//  UserAccountView.swift
//  TrakShow
//
//  Created by Gabriel Mannheimer on 2/9/24.
//

import SwiftUI

struct UserAccountView: View {
    @StateObject var trakShowManager: TrakShowManager
    @State private var choice = "ShowListing"
    @State private var choices = ["ShowListing", "Following"]
    @State private var search: String = ""
    var body: some View {
        ZStack{
            trakShowManager.bkgrColor.ignoresSafeArea()
            VStack{
                Picker("View", selection: $choice){
                    ForEach(choices, id: \.self){
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                Text(trakShowManager.email ?? "No Email")
                    .foregroundStyle(Color.white)
                
                if(choice == "ShowListing"){
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(trakShowManager.watchList, id: \.self){ tvShow in
                                Text(tvShow.name)
                                    .padding()
                                    .background(trakShowManager.logintxtColor)
                                    .foregroundStyle(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    List{
                        ForEach(trakShowManager.watchList, id: \.self){ tvShow in
                            Button(action:{
                                Task{
                                    try await trakShowManager.fullSelectedShow = trakShowManager.tvshowApi.performApiCall(id: tvShow.id)
                                    trakShowManager.selectedShowView = true
                                    trakShowManager.userView = false
                                }
                            })
                            {
                                Text(tvShow.name)
                                    .foregroundStyle(.white)
                            }
                            .swipeActions(edge: .trailing) {
                                Button("Delete") {
                                    Task{
                                        await trakShowManager.deleteShow(show: tvShow)
                                    }
                                }
                                .tint(.red)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .listRowBackground(trakShowManager.logintxtColor)
                        
                    }
                    .scrollContentBackground(.hidden)
                    .background(trakShowManager.bkgrColor)
                }
                else{
                    
                    List{
                        ForEach(trakShowManager.followingList, id: \.self){username in
                            Text(username)
                                .padding()
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(trakShowManager.bkgrColor)
                    
                }
                Button(action:{
                    Task{
                        do{
                            trakShowManager.signOut()
                        }
                    }
                    DispatchQueue.main.async {
                        trakShowManager.isLoginView = true
                        trakShowManager.exploreView = false
                        trakShowManager.selectedShowView = false
                        trakShowManager.userView = false
                        trakShowManager.signUpView = false
                    }
                }){
                    Text("Logout")
                        .foregroundStyle(Color.black)
                        .padding()
                        .frame(width: 100, height: 50)
                        .background(trakShowManager.btnColor)
                        .cornerRadius(20)
                }
            }
        }
        .onAppear(){
            Task{
                print("List Appearing")
                await trakShowManager.getUserShowList()
                await trakShowManager.getFollowers()
            }
        }
        .onAppear(){
            trakShowManager.screenInt = 3
        }
    }
}

#Preview {
    UserAccountView(trakShowManager: TrakShowManager())
}
