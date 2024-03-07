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

struct FirebaseTvShow : Hashable{
    var name: String
    var id: Int
    var curEpNum: Int
    var curSeason: Int
    var maxEpCurSeason: Int
}

struct TVPost: Hashable{
    var email: String
    var comment: String
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
    //ExploreView int is 2
    //Accountview is 3
    @Published var screenInt = 0
    @Published var isLoginView = true
    @Published var exploreView = false
    @Published var selectedShowView = false
    @Published var userView = false
    @Published var signUpView = false
    @Published var feedView = false
    
    //Explore View
    @Published var tvShows: [TVShow] = []
    @Published var lastPageOn: Int?
    let tvshowApi = TvShowApi()
    
    //TVShowView
    @Published var selectedShow: TVShow?
    @Published var fullSelectedShow: TVShowSelected?
    @Published var isAdded = false
    
    //firebase/User
    @Published var watchList: [FirebaseTvShow] = []
    @Published var epsInSeason = 0
    @Published var followingList: [String] = []
    
    
    //FeedView
    @Published var feedList: [TVPost] = []
    
    
    override init()
    {
        super.init()
        firebaseManager = FirebaseManager(trakshowManager: self)
        lastPageOn = 1
    }
    
    func userNameStuff() async -> Void
    {
        await firebaseManager?.getUsersFromDatabase(email: "slackurpackage@gmail.com")
    }
    
    func getAllUsers() async -> Void
    {
        
        var users = await firebaseManager?.getAllFirebaseUsers()
        
    }
    
    func callTvShowApi() async -> Void{
        var curCount = 0
        do{
            fullSelectedShow = try await tvshowApi.performApiCall(id: selectedShow?.id ?? 0)
        }
        catch{
            //print("this the error printing")
            print(String(describing: error))
        }
        
        epsInSeason = curCount
        //print(epsInSeason)
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
    
    func loginWithGoogle() async{
        if let curemail = await firebaseManager?.performGoogleSignIn(){
            var users = await firebaseManager?.getAllFirebaseUsers()
            if users?.contains(curemail) == false{
                await firebaseManager?.addUser(email: curemail)
            }
            else{
                print("nigga is already in there")
            }
            email = curemail
            isLoginView = false
            exploreView = true
        }
    }
    
    
    func getShows(search: String, page: Int) async{
        //print("UH INSIDE THE SHIT")
        do{
            tvShows = try await tvshowApi.getShows(search: search, page: page)
            try await tvshowApi.tvmazeapi(search: search)
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    func addShowToList() async{
        do{
            await firebaseManager?.addShowToList(email: email ?? "", show: (fullSelectedShow)!)
            let wList = await firebaseManager?.getShowList(email: email ?? "")
            watchList = wList ?? watchList
            
        }
    }
    
    
    func getUserShowList() async{
        do{
            //print("Get Show List func Email: \(email)")
            let wList = await firebaseManager?.getShowList(email: email ?? "")
            if let showList = wList{
                DispatchQueue.main.async{
                    for curShow in showList{
                        if !self.watchList.contains(where: { $0.name == curShow.name }){
                            self.watchList.append(curShow)
                        }
                    }
                }
            }
        }
    }
    
    func ifShowExsist() async{
        do{
            if let myBool = await firebaseManager?.ifShowExsits(email: email ?? "", show: (fullSelectedShow)!)
            {
                //print(myBool)
                isAdded = myBool
            }
            
        }
    }
    
    func updateEp(epBool: Bool, completion: @escaping () -> Void) async {
        var theShow: FirebaseTvShow
        do{
            //Check if this the first ep of the season and get eps per season
                for curshow1 in watchList{
                    if fullSelectedShow?.name == curshow1.name{
                        theShow = curshow1
                        if epBool == false{
                            if curshow1.curEpNum - 1 <= 1{
                                if let episodes = fullSelectedShow?.episodes{
                                    var epCount = 0
                                    for ep in episodes{
                                        if curshow1.curSeason - 1 == ep.season{
                                            epCount += 1
                                        }
                                    }
                                    theShow.maxEpCurSeason = epCount
                                }
                            }
                        }
                        await firebaseManager?.updateEP(email: email ?? "", show: theShow, epBool: epBool, fullShow: fullSelectedShow!)
                        let wList = await firebaseManager?.getShowList(email: email ?? "")
                        watchList = wList ?? watchList
                        completion()
                    }
                }
        }
    }
    
    func deleteShow(show: FirebaseTvShow) async{
        //print(show.name)
        do{
            for curshow1 in watchList{
                if curshow1.id == show.id{
                    await firebaseManager?.deleteShow(email: email ?? "", show: curshow1)
                }
            }
            let wList = await firebaseManager?.getShowList(email: email ?? "")
            watchList = wList ?? watchList
        }
    }
    
    func signUp(email: String, password: String) async{
        do{
            try await firebaseManager?.signInWithEmailPassword(email: email, password: password)
        }
        catch{
            print(String(describing: error))
        }
    }
    
    func getFollowers() async{
        do{
            if let following = try await firebaseManager?.getFollowers(email: email ?? ""){
                followingList = following
            }
            
        }
        catch{
            print(String(describing: error))
        }
    }
    
    func signOut(){
        Task{
            do{
                await firebaseManager?.signOut()
                DispatchQueue.main.async {
                    self.watchList = []
                }
            }
            }
    }
    
    func getPosts(){
        Task{
            do{
                print(":/")
                if let feedList1 = await firebaseManager?.getPosts(){
                    feedList = feedList1
                }
            }
        }
    }

}

