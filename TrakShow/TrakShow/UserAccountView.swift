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
    @State private var selectedShow: FirebaseTvShow?
    @State private var curSeason = 0
    @State private var curEp = 0
    @State private var watchList: [FirebaseTvShow] = []
    @State private var isShow = false
    @State private var curEpName = ""
    var body: some View {
        ZStack{
            trakShowManager.bkgrColor.ignoresSafeArea()
            //ScrollView{
            VStack(spacing: 3){
                    Picker("View", selection: $choice){
                        ForEach(choices, id: \.self){
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    /*
                    Text(trakShowManager.email ?? "No Email")
                        .foregroundStyle(Color.white)
                     */
                    
                    if(choice == "ShowListing"){
                        ScrollView(.horizontal) {
                            LazyHStack {
                                ForEach(trakShowManager.watchList, id: \.self){ tvShow in
                                    Button(action:{
                                        Task{
                                                
                                                await trakShowManager.setMazeShow(id: tvShow.id)
                                                //trakShowManager.selectedShowView = true
                                                //trakShowManager.userView = false
                                                //print("Season: \(tvShow.curSeason) Ep: \(tvShow.curEpNum)")
                                                selectedShow = tvShow
                                                //print("INSIDE OF USER Season: \(tvShow.curSeason)Ep:\(tvShow.curEpNum)")
                                                await trakShowManager.getMazeSingleShow()
                                                curEp = selectedShow?.curEpNum ?? 0
                                                curSeason = selectedShow?.curSeason ?? 0
                                                isShow = true
                                                
                                            
                                        }
                                    }){
                                        VStack{
                                            if let imageUrl = URL(string: tvShow.imgString) {
                                                
                                                AsyncImage(url: imageUrl) { image in
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 235, height: 235)
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                                
                                            } else {
                                                Text("No Image")
                                                    .foregroundStyle(.white)
                                            }
                                            Text(tvShow.name)
                                                .padding()
                                                .background(trakShowManager.logintxtColor)
                                                .foregroundStyle(.white)
                                                .cornerRadius(8)
                                        }
                                    }
                                    .onChange(of: trakShowManager.mazeSelectedShowEpisodes){
                                        curEpName = trakShowManager.mazeSelectedShowEpisodes.first(where: { $0.season == curSeason && $0.number == curEp})?.name ?? ""
                                    }
                                    .onChange(of: curSeason){
                                        curEpName = trakShowManager.mazeSelectedShowEpisodes.first(where: { $0.season == curSeason && $0.number == curEp})?.name ?? ""
                                    }
                                    .onChange(of: curEp){
                                        curEpName = trakShowManager.mazeSelectedShowEpisodes.first(where: { $0.season == curSeason && $0.number == curEp})?.name ?? ""
                                    }
                                }
                            }
                        }
                        
                        
                        if trakShowManager.mazeSelectedShow != nil && isShow == true{
                            VStack{
                                //Text("S:\(selectedShow?.curSeason ?? 0) Ep:\(selectedShow?.curEpNum ?? 0)")
                                Text("Selected: \(selectedShow?.name ?? "")")
                                    .padding(1)
                                    .foregroundStyle(.white)
                                HStack(spacing: 10){
                                    Button(action:{
                                        Task{
                                            await trakShowManager.updateEp(epBool: false, completion: {})
                                            //await trakShowManager.getUserShowList()
                                            watchList = trakShowManager.watchList
                                            selectedShow = trakShowManager.watchList.first(where: { $0.name == selectedShow?.name })
                                            curSeason = selectedShow?.curSeason ?? 0
                                            curEp = selectedShow?.curEpNum ?? 0
                                        }
                                    }){
                                        Text("-")
                                    }
                                    
                                    Text("S:\(curSeason) Ep:\(curEp)")
                                        .padding(5)
                                        .foregroundStyle(.white)
                                    Button(action:{
                                        Task{
                                            await trakShowManager.updateEp(epBool: true, completion: {})
                                            //await trakShowManager.getUserShowList()
                                            watchList = trakShowManager.watchList
                                            selectedShow = trakShowManager.watchList.first(where: { $0.name == selectedShow?.name })
                                            curSeason = selectedShow?.curSeason ?? 0
                                            curEp = selectedShow?.curEpNum ?? 0
                                        }
                                    }){
                                        Text("+")
                                    }
                                }
                                
                               
                                Text(curEpName)
                                    .padding()
                                    .foregroundStyle(.white)
                                HStack{
                                    Button(action:{
                                        trakShowManager.selectedShowView = true
                                        trakShowManager.userView = false
                                        isShow = false
                                    }){
                                        Text("Show Page")
                                            .foregroundStyle(Color.black)
                                            .font(.system(size: 15))
                                            .padding()
                                            .frame(width: 150, height: 50)
                                            .background(trakShowManager.btnColor)
                                            .cornerRadius(20)
                                    }
                                    .padding()
                                    Button(action:{
                                        Task{
                                            if let sshow = selectedShow {
                                                await trakShowManager.deleteShow(show: sshow)
                                            }
                                            isShow = false
                                        }
                                    }){
                                        Text("Delete Show")
                                            .foregroundStyle(Color.black)
                                            .font(.system(size: 15))
                                            .padding()
                                            .frame(width: 150, height: 50)
                                            .background(trakShowManager.btnColor)
                                            .cornerRadius(20)
                                    }
                                    .padding()
                                }
                            }
                        }
                    }
                
                //Following
                    else{
                        HStack(spacing: 1){
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
                            
                            Button(action: {
                                trakShowManager.userSeacrh = true
                                trakShowManager.userView = false
                            }){
                                Image(systemName: "person.badge.plus")
                                    .padding(.trailing)
                            }
                        }
                        
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
                
                Spacer(minLength: 12)
                }
            }
            .onAppear(){
                Task{
                    //print("List Appearing")
                    await trakShowManager.getUserShowList()
                    await trakShowManager.getFollowers()
                    await trakShowManager.getMazeSingleShow()
                    curEp = selectedShow?.curEpNum ?? 0
                    curSeason = selectedShow?.curSeason ?? 0
                }
            }
            .onAppear(){
                trakShowManager.screenInt = 3
            }
        //}//scroll view
    }
}

 #Preview {
 UserAccountView(trakShowManager: TrakShowManager())
 }
 
