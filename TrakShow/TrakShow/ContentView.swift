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
        if(trakshowManager.exploreView == true)
        {
            ExploreView(trakShowManager: trakshowManager)
        }
        
        else if (trakshowManager.selectedShowView == true)
        {
            TvShowView(trakShowManager: trakshowManager)
        }
        
        else
        {
            LoginView(trakShowManager: trakshowManager)
        }

    }
}

#Preview {
    ContentView(trakshowManager: TrakShowManager())
}
