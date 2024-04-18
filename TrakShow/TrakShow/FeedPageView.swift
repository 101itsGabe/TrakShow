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
        ZStack{
            trakShowManager.bkgrColor.ignoresSafeArea()
            VStack{
                //Text("The Feed")
                //trakShowManager.bkgrColor.ignoresSafeArea()
                List{
                    ForEach(trakShowManager.feedList, id: \.self){post in
                        VStack{
                            HStack{
                                Text(post.email)
                                    .padding()
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            Text(post.comment)
                                .padding()
                                .foregroundStyle(.white)
                            HStack{
                                Button(action:{}){
                                    Image(systemName: "hand.thumbsup")
                                        .padding()
                                        .foregroundStyle(.white)
                                }
                                Spacer()
                                Spacer()
                            }
                        }
                        .background(trakShowManager.bkgrColor)
                        
                    }
                    
                }
                .scrollContentBackground(.hidden)
                .refreshable {
                    trakShowManager.getPosts()
                }
                .listStyle(.plain)
                //.scrollContentBackground(.hidden)
                .foregroundStyle(trakShowManager.bkgrColor)
                //.background(trakShowManager.bkgrColor)
                
            }
            .onAppear(){
                trakShowManager.getPosts()
            }
        }
    }
}

#Preview {
    FeedPageView(trakShowManager: TrakShowManager())
}
