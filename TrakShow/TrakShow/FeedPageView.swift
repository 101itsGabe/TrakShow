//
//  FeedPageView.swift
//  TrakShow
//
//  Created by Gabriel Mannheimer on 2/28/24.
//

import SwiftUI

struct FeedPageView: View {
    @StateObject var trakShowManager: TrakShowManager
    var body: some View {
        VStack{
            Text("Pluto sent you on a lick")
            List{
                ForEach(trakShowManager.feedList, id: \.self){post in
                    VStack{
                        HStack{
                            Text(post.email)
                            Spacer()
                        }
                        Text(post.comment)
                            .padding()
                    }
                    
                }
            }
            .refreshable {
                trakShowManager.getPosts()
            }
            
        }
        .onAppear(){
            trakShowManager.getPosts()
        }
    }
}

#Preview {
    FeedPageView(trakShowManager: TrakShowManager())
}
