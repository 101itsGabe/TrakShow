//
//  ContentView.swift
//  TrakShow
//
//  Created by Gabriel Mannheimer on 2/7/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var trakshowManager: TrakShowManager
    var body: some View {
        ZStack{
            trakshowManager.bkgrColor.ignoresSafeArea()
            VStack{
                Spacer()
                if(trakshowManager.exploreView == true)
                {
                    ExploreView(trakShowManager: trakshowManager)
                }
                
                else if (trakshowManager.selectedShowView == true)
                {
                    TvShowView(trakShowManager: trakshowManager)
                }
                
                else if(trakshowManager.userView == true)
                {
                    UserAccountView(trakShowManager: trakshowManager)
                }
                else if (trakshowManager.signUpView == true){
                    SignUpView(trakShowManager: trakshowManager)
                }
                
                else
                {
                    LoginView(trakShowManager: trakshowManager)
                }
                Spacer()
                if trakshowManager.isLoginView == false{
                    
                    ZStack{
                        trakshowManager.logintxtColor.ignoresSafeArea()

                        HStack{
                            
                            Spacer()
                            Button(action:{
                                //User feed
                            })
                            {
                                Image(systemName: "book.pages")
                                    .foregroundStyle(Color.white)
                                    .padding()
                                    .scaleEffect(1.3)
                            }
                            Spacer()
                            Button(action:{
                                trakshowManager.userView = true
                                trakshowManager.selectedShowView = false
                                trakshowManager.exploreView = false
                            })
                            {
                                Image(systemName: "person.crop.square")
                                    .foregroundStyle(Color.white)
                                    .padding()
                                    .scaleEffect(1.3)
                            }
                            Spacer()
                            Button(action:{})
                            {
                                Image(systemName: "list.and.film")
                                    .foregroundStyle(Color.white)
                                    .padding()
                                    .scaleEffect(1.3)
                            }
                            Spacer()
                            Button(action:{
                                trakshowManager.userView = false
                                trakshowManager.selectedShowView = false
                                trakshowManager.exploreView = true
                            })
                            {
                                Image(systemName: "swirl.circle.righthalf.filled")
                                    .foregroundStyle(Color.white)
                                    .padding()
                                    .scaleEffect(1.3)
                            }
                            Spacer()
                        }
                        
                    }
                    .frame(height: 20)
                }
            }
        }
    }
}

#Preview {
    ContentView(trakshowManager: TrakShowManager())
}
