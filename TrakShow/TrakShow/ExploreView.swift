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
                                await trakShowManager.getShows(search: newValue)
                                
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
                            print(trakShowManager.selectedShow?.name ?? "" )
                            trakShowManager.exploreView = false
                            trakShowManager.selectedShowView = true
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
                                                }
                                Text(tvShow.name)
                            }
                            .contentShape(Rectangle())
                        }
                    }
                }
                    .onAppear(){
                        Task{
                            await trakShowManager.callTvShowApi()
                            await trakShowManager.getShows(search: search)
                        }
                    }
                    .onChange(of: search)
                { _ in
                    Task{
                        await trakShowManager.getShows(search: search)
                    }
                }
                .foregroundColor(trakShowManager.bkgrColor)
                .background(trakShowManager.bkgrColor)
            }
        }
    }
    
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
    ExploreView(trakShowManager: TrakShowManager())
}
