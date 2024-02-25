//
//  ExploreView.swift
//  TrakShow
//
//  Created by Gabriel Mannheimer on 2/8/24.
//

import SwiftUI

struct ExploreView: View {
    @StateObject var trakShowManager: TrakShowManager
    @State private var search: String = ""
    @State private var imageData: Data? = nil
    @State private var curPage: Int?
    @State private var imageCache: [String: Data] = [:]
    @State private var curimg: Image?

    var body: some View {
        ZStack{
            trakShowManager.bkgrColor.ignoresSafeArea()
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
                            await trakShowManager.getShows(search: newValue, page: curPage ?? 1)
                                
                            }
                        }
                }
                .foregroundColor(.white)
                .frame(width:350, height: 50)
                .background(trakShowManager.logintxtColor)
                .cornerRadius(20)
                .padding()
                
                Spacer()
                
                List{
                    ForEach(trakShowManager.tvShows, id: \.self){ tvShow in
                        Button(action:{
                            trakShowManager.selectedShow = tvShow
                            trakShowManager.exploreView = false
                            trakShowManager.selectedShowView = true
                            trakShowManager.lastPageOn = curPage
                        }){
                            HStack{
                                if let imageUrl = URL(string: tvShow.image_thumbnail_path ?? "") {
                                                    AsyncImage(url: imageUrl) { image in
                                                        image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 125, height: 125)
                                                    } placeholder: {
                                                        ProgressView()
                                                    }
                                   
                                                } else {
                                                    Text("No Image")
                                                        .foregroundStyle(.white)
                                                }
                                Text(tvShow.name)
                                    .foregroundStyle(.white)
                                    .padding()
                                    .bold()
                            }
                            .contentShape(Rectangle())
                        }
                    }
                    .listStyle(PlainListStyle())
                    .listRowBackground(trakShowManager.bkgrColor)
                }
                    .onAppear(){
                        curPage = trakShowManager.lastPageOn
                        Task{
                            await trakShowManager.getShows(search: search, page: curPage ?? 1)
                        }
                    }
                    .onChange(of: search){ _ in
                        Task{
                            await trakShowManager.getShows(search: search, page: curPage ?? 1)
                    }
                }
                    .onChange(of: curPage){ _ in
                        Task{
                            print("HELLO CHANGING PAGE")
                            await trakShowManager.getShows(search: search, page: curPage ?? 1)
                        }
                        
                    }
                    .foregroundStyle(.black)
                .background(trakShowManager.bkgrColor)
                .scrollContentBackground(.hidden)

                
                HStack{
                    Spacer()
                    Button(action:{
                        if curPage ?? 0 > 1
                        {
                            curPage? -= 1
                        }
                    }){
                        Image(systemName:"arrow.left")
                            .foregroundStyle(.white)
                            .padding()
                    }
                    Spacer()
                    Text(String(curPage ?? 0))
                        .foregroundStyle(.white)
                    Spacer()
                    Button(action:{
                        curPage? += 1
                    }){
                        Image(systemName:"arrow.right")
                            .foregroundStyle(.white)
                            .padding()
                    }
                    Spacer()
                }
            }
        }
        .onAppear(){
            trakShowManager.screenInt = 2
        }
    }

}

#Preview {
    ExploreView(trakShowManager: TrakShowManager())
}
