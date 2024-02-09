//
//  TvShowView.swift
//  TrakShow
//
//  Created by Gabriel Mannheimer on 2/8/24.
//

import SwiftUI

struct TvShowView: View {
    @StateObject var trakShowManager: TrakShowManager
    @State private var imageData: Data? = nil
    var body: some View {
        VStack{
            Text(trakShowManager.selectedShow?.name ?? "")
            if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
            } else {
                ProgressView() // Show a loading indicator while fetching the image
            }
        }
        .onAppear(){
            print("APPEARING?")
            print(trakShowManager.selectedShow?.image_thumbnail_path ?? "else")
            LoadImage(imageUrlString: trakShowManager.selectedShow?.image_thumbnail_path ?? "")
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
    TvShowView(trakShowManager: TrakShowManager())
}
