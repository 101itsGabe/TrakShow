//
//  TvShowView.swift
//  TrakShow
//
//  Created by Gabriel Mannheimer on 2/8/24.
//

import SwiftUI

struct TvShowView: View {
    @ObservedObject var trakShowManager: TrakShowManager
    @State private var imageData: Data? = nil
    @State private var selectedEpisodeIndex = 0
    var body: some View {
        ScrollView{
            ZStack{
                trakShowManager.bkgrColor.ignoresSafeArea()
                VStack{
                    Button(action:{
                        if trakShowManager.screenInt == 2{
                            trakShowManager.exploreView = true
                            trakShowManager.selectedShowView = false
                            trakShowManager.fullSelectedShow = nil
                            trakShowManager.selectedShow = nil
                        }
                        else if trakShowManager.screenInt == 3{
                            trakShowManager.userView = true
                            trakShowManager.selectedShowView = false
                            trakShowManager.fullSelectedShow = nil
                            trakShowManager.selectedShow = nil
                        }
                    }){
                        HStack{
                            Image(systemName: "arrow.left")
                                .padding()
                                .foregroundColor(.white)
                                .scaleEffect(1.3)
                            Spacer()
                            
                            Text(trakShowManager.fullSelectedShow?.name ?? "")
                                .padding(.trailing)
                                .bold()
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            Spacer()
                            Text("")
                        }
                    }//Button
                    ZStack{
                        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                            //.frame(width: 225, height: 225)
                        } else {
                            ProgressView() // Show a loading indicator while fetching the image
                        }
                        VStack{
                            Spacer()
                            Text("")
                                .padding()
                                .bold()
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            /*
                             if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                             Image(uiImage: uiImage)
                             .resizable()
                             .aspectRatio(contentMode: .fit)
                             .frame(width: 225, height: 225)
                             } else {
                             ProgressView() // Show a loading indicator while fetching the image
                             }
                             */
                            if let rating = trakShowManager.fullSelectedShow?.rating{
                                Text("Rating: \(rating)/10")
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    ScrollView{
                        Text(trakShowManager.fullSelectedShow?.description ?? "Desc")
                            .foregroundStyle(.white)
                            .padding()
                    }
                    .frame(height: 200)
                    
                    Button(action: {
                        if trakShowManager.isAdded == false {
                            Task{
                                await trakShowManager.addShowToList()
                                trakShowManager.isAdded = true
                            }
                        }})
                    {
                        if trakShowManager.isAdded == false {
                            Text("Add This Show")
                                .foregroundStyle(Color.black)
                                .font(.system(size: 15))
                                .padding()
                                .frame(width: 200, height: 40)
                                .background(trakShowManager.btnColor)
                                .cornerRadius(20)
                        }
                        else{
                            HStack{
                                Text("Show Added")
                                    .foregroundStyle(Color.black)
                                    .font(.system(size: 15))
                                    .padding()
                                Image(systemName: "checkmark.circle")
                                    .padding()
                                    .foregroundColor(.white)
                            }
                            .frame(width: 200, height: 45)
                            .background(.gray)
                            .cornerRadius(20)
                        }
                    }
                    
                    if trakShowManager.isAdded == true {
                        
                         ForEach(trakShowManager.watchList, id: \.self) { curShow in
                         if curShow.name == trakShowManager.fullSelectedShow?.name {
                         if let episodes = trakShowManager.fullSelectedShow?.episodes{
                         ForEach(episodes, id: \.self) { ep in
                         if ep.episode == curShow.curEpNum && ep.season == curShow.curSeason{
                         Text("Season: \(curShow.curSeason) Ep: \(curShow.curEpNum) \(ep.name)")
                         .padding()
                         .foregroundStyle(.white)
                         }
                         }
                         
                         }
                         }
                         }
                         
                        
                        Picker(selection: $selectedEpisodeIndex, label: Text("Select Episode")) {
                                        ForEach(trakShowManager.fullSelectedShow?.episodes ?? [], id: \.self) { index in
                                            Text("Season: \(index.season) Ep: \(index.episode), \(index.name)")
                                                .foregroundStyle(.white)
                                        }
                                    }
                                    .pickerStyle(WheelPickerStyle())
                        

                        /*
                        HStack{
                            Button(action:{
                                Task{
                                    await trakShowManager.updateEp(epBool: false, completion: {})
                                }
                            })
                            {
                                Text("< Prev Ep")
                                    .padding()
                            }
                            Text("-")
                                .padding()
                                .foregroundStyle(.white)
                            Button(action:{
                                Task{
                                    await trakShowManager.updateEp(epBool: true, completion: {})
                                    }
                                }
                            )
                            {
                                Text("Next Ep >")
                                    .padding()
                            }
                        }
                        */
                    }
                    
                    else{
                        if let episodes = trakShowManager.fullSelectedShow?.episodes{
                            List{
                                ForEach(episodes, id: \.self){ episode in
                                    Text("Season: \(episode.season), EP: \(episode.episode) \(episode.name)")
                                        .foregroundStyle(.white)
                                }
                                .listRowBackground(trakShowManager.bkgrColor)
                                
                            }.scrollContentBackground(.hidden)
                        }
                    }
                    
                    
                }
                .onAppear(){
                    Task{
                        if(trakShowManager.selectedShow != nil)
                        {
                            await trakShowManager.callTvShowApi()
                        }
                        LoadImage(imageUrlString: trakShowManager.fullSelectedShow?.image_thumbnail_path ?? "")
                        
                        await trakShowManager.ifShowExsist()
                        
                        
                    }
                }
                
                Spacer()
            }
        }
    }
    
    
    
    
    //LOAD IMAGE FUNC
    func LoadImage(imageUrlString: String){
        print(imageUrlString)
        guard let imageUrl = URL(string: imageUrlString) else { return }
        print(imageUrlString)
        print("HEHE")
        URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                    guard let data = data, error == nil else {
                        print("Failed to fetch image:", error?.localizedDescription ?? "Unknown error")
                        return
                    }
            DispatchQueue.main.async {
                            imageData = data
                        }
                    }.resume()
        
    }
        

}


#Preview {
    TvShowView(trakShowManager: TrakShowManager())
}
