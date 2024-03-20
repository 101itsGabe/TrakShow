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
    @State var selectedEp: MazeEpisode?
    var body: some View {
        NavigationStack{
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
                            trakShowManager.printStuff()
                        }){
                            HStack{
                                Image(systemName: "arrow.left")
                                    .padding()
                                    .foregroundColor(.white)
                                    .scaleEffect(1.3)
                                Spacer()
                                
                                Text(trakShowManager.mazeSelectedShow?.name ?? "")
                                    .padding(.trailing)
                                    .bold()
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                Spacer()
                                Text("")
                                Spacer()
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
                                
                                
                            }
                        }
                        ScrollView{
                            
                            Text(trakShowManager.mazeSelectedShow?.summary ?? "Desc")
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
                                if curShow.name == trakShowManager.mazeSelectedShow?.name {
                                    ForEach(trakShowManager.mazeSelectedShowEpisodes, id: \.self) { ep in
                                        if let name = ep.name{
                                            if ep.number == curShow.curEpNum && ep.season == curShow.curSeason{
                                                Text("Season: \(curShow.curSeason) Ep: \(curShow.curEpNum) \(name)")
                                                    .padding()
                                                    .foregroundStyle(.white)
                                            }
                                        }
                                        
                                    }
                                }
                            }
                            
                            
                        }
                        
                        if let curEp = selectedEp{
                            if let num = curEp.number, let season = curEp.season{
                                Text("Season: \(season) Ep: \(num): \(curEp.name ?? "no")")
                                    .foregroundStyle(.white)
                            }
                        }
                        else{
                            Text("Select an Episode")
                                .foregroundStyle(.white)
                        }
                        

                        Picker(selection: $selectedEp, label: Text("Select Episode")) {
                                ForEach(trakShowManager.mazeSelectedShowEpisodes , id: \.self) { ep in
                                    //let ep2 = trakShowManager.mazeSelectedShowEpisodes[selectedEpisodeIndex]
                                    
                                    //if let season = ep.season, let num = ep.number{
                                    Text("Season:\(ep.season ?? 0) Ep: \(ep.number ?? 0) \(ep.name ?? "no")")
                                        .tag(ep as? MazeEpisode)
                                        .foregroundStyle(.white)
                                }
                            }
                            .pickerStyle(DefaultPickerStyle())
                            
                            
                   
                   
                        }
                        .padding()
                
                         
                        
                        
                    }
                    .onAppear(){
                        Task{
                            if trakShowManager.mazeSelectedShow != nil{
                                await trakShowManager.getMazeSingleShow()
                            }
                            
                            LoadImage(imageUrlString: trakShowManager.mazeSelectedShow?.image?.original ?? "")
                            
                            await trakShowManager.ifShowExsist()
                            
                            
                        }
                    }
                }
                .gesture(DragGesture()
                    .onChanged{ gesture in
                        if gesture.location.x < CGFloat(80){
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
                        }
                        
                    })
                
                Spacer()
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
