//
//  TrakShowManager.swift
//  TrakShow
//
//  Created by Gabriel Mannheimer on 2/7/24.
//

import Foundation
import SwiftUI

struct User
{
    var email: String?
    var userName: String?
}
class TrakShowManager: NSObject, ObservableObject
{
    @Published var curUser = User()
    @Published var email: String?
    @Published var userName: String?
    @Published var password: String?
    @Published var firebaseManager: FirebaseManager?
    @Published var isLoggededIn = false
    @Published var btnColor = Color(red: (230/255), green: (170/255), blue: (235/255))
    @Published var logintxtColor = Color(red: 83/255, green: 99/255, blue: 137/255)
    @Published var bkgrColor = Color(red: 52/255, green: 64/255, blue: 92/255)
    @Published var textColor = Color(red: 60/255, green: 50/255, blue: 50/255)
    
    //views
    @Published var isLoginView = true
    @Published var exploreView = false
    @Published var selectedShowView = false
    
    //Explore View
    @Published var tvShows: [TVShow] = []
    let tvshowApi = TvShowApi()
    
    //TVShowView
    @Published var selectedShow: TVShow?
    
    
    override init()
    {
        super.init()
        firebaseManager = FirebaseManager(trakshowManager: self)
    }
    
    func userNameStuff() async -> Void
    {
        await firebaseManager?.getUsersFromDatabase(email: "slackurpackage@gmail.com")
    }
    
    func getAllUsers() async -> Void
    {
        await firebaseManager?.getAllFirebaseUsers()
    }
    
    func callTvShowApi() async -> Void{
        do{
            try await print(tvshowApi.performApiCall())
        }
        catch{
            print("this the error printing")
            print(error.localizedDescription)
        }
    }
    
    func loginWithEmailPassword(email: String, password: String) async
    {
        do{
            try await firebaseManager?.signInWithEmailPassword(email: email.lowercased(), password: password)
            isLoginView = false
            exploreView = true
        }
        catch{
            print("Somethings wrong bucko")
        }
    }
    
    func getShows(search: String) async{
        do{
            tvShows = try await tvshowApi.getShows(search: search)
        }
        catch{
            print(error.localizedDescription)
        }
    }

}

