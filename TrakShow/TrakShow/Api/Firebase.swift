//
//  Firebase.swift
//  TrakShow
//
//  Created by Gabriel Mannheimer on 2/7/24.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import Firebase
import FirebaseDatabase
import GoogleSignIn
import GoogleSignInSwift
import FirebaseFirestore


class FirebaseManager: NSObject, ObservableObject{
    @Published var trakshowmanager: TrakShowManager?
    @Published private var epsInSeason = 0
    
    init(trakshowManager: TrakShowManager)
    {
        super.init()
    }
    
    func getUsersFromDatabase(email: String) async{
        let databse = Firestore.firestore()
        let userCollection = databse.collection("Users")
        do{
            let querySnapshot = try await userCollection.whereField("email", isEqualTo: email.lowercased()).getDocuments()
            
            if !querySnapshot.isEmpty{
                for document in querySnapshot.documents{
                    let data = document.data()
                    print(data["email"].debugDescription)
                    trakshowmanager?.email = data["email"].debugDescription
                }
            }
        }
        catch{
            print("Something Happened")
        }
    }
    
    
    //Check if user is already in db
    func performGoogleSignIn() async -> String{
        var email = ""
        enum SignInError: Error{
            case idTokenMissing
        }
        let signInConfig = GIDConfiguration(clientID: FirebaseApp.app()?.options.clientID ?? "")
        
        GIDSignIn.sharedInstance.configuration = signInConfig
        
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = await windowScene.windows.first,
                      let rootViewController = await window.rootViewController else{
                    print("There is not root view controller")
                    return email
                }
        do{
            let userAuth = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let user = userAuth.user
            guard let idToken = user.idToken else{
                throw SignInError.idTokenMissing
            }
            
            let accessToken = user.accessToken
            let credentials = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
            do{
                let results = try await Auth.auth().signIn(with: credentials)
                let firebaseUser = results.user
                //print(results.user.email ?? "")
                email = results.user.email ?? ""
                //print(email)
            }
            catch{
                print(error.localizedDescription)
            }
            
            return email
        }
        catch{
            print(error.localizedDescription)
            return email
        }
    }
    
    func getAllFirebaseUsers() async -> [String]
    {
        var users: [String] = []
        let db = Firestore.firestore()
        let userCollection = db.collection("Users")
        do
        {
            let querySnapshot = try await userCollection.getDocuments()
            for document in querySnapshot.documents
            {
                if let email = document.data()["email"] as? String
                {
                    //print("WE BACK EMAIL: \(email)")
                    users.append(email)
                }
            }
        }
        catch{
            print(error)
        }
        
        return users
    }
    
    func signInWithEmailPassword(email: String, password: String) async throws {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email.lowercased(), password: password)
            // If sign-in is successful, proceed
            print("Logged In!")
            self.trakshowmanager?.email = email
        } catch {
            // If there's an error during sign-in, handle it
            print(error.localizedDescription)
            throw error // Rethrow the error to propagate it to the caller
        }
    }
    
    func getShowList(email: String) async -> [FirebaseTvShow]{
        var showList: [FirebaseTvShow] = []
        let database = Firestore.firestore()
        let userCollection = database.collection("Users")
        do{
            let querySnapshot = try await userCollection.whereField("email", isEqualTo: email.lowercased()).getDocuments()
            
            //meaning something IS there
            if !querySnapshot.isEmpty{
                for document in querySnapshot.documents{
                    //let data = document.data()
                    let id = document.documentID
                    //let email = data["email"].debugDescription
                    let userDocRef = userCollection.document(id)
                    // Access the subcollection "tvshows"
                    let showCollection = userDocRef.collection("tvshows")
                    let showQuerySnapshot = try await showCollection
                        .order(by: "timestamp", descending: true)
                        .getDocuments()
                    
                    // Iterate through documents in "tvshows" collection
                    for showDocument in showQuerySnapshot.documents {
                        var CurShow = FirebaseTvShow(name: "", id: 0, curEpNum: 0, curSeason: 0, maxEpCurSeason: 0)
                        let showData = showDocument.data()
                        if let showName = showData["name"] as? String
                        {
                            CurShow.name = showName
                        }
                        if let showID = showData["id"] as? Int{
                            CurShow.id = showID
                        }
                        if let epNum = showData["curepnum"] as? Int{
                            CurShow.curEpNum = epNum
                        }
                        
                        if let curSeason = showData["curseason"] as? Int{
                            CurShow.curSeason = curSeason
                        }
                        if let maxEpSeason = showData["epsInSeason"] as? Int{
                            CurShow.maxEpCurSeason = maxEpSeason
                        }
                        
                        showList.append(CurShow)
                            
                    }
                }
            }
        }
        catch{
            print(String(describing: error))
        }
        
        return showList
    }
    
    func ifShowExsits(email: String, show: TVShowSelected) async -> Bool{
        let database = Firestore.firestore()
        let userCollection = database.collection("Users")
        var isAdded = false
        do{
            let querySnapshot = try await userCollection.whereField("email", isEqualTo: email.lowercased()).getDocuments()
            
            //meaning something IS there
            if !querySnapshot.isEmpty{
                for document in querySnapshot.documents{
                    let id = document.documentID
                    let userDocRef = userCollection.document(id)
                    // Access the subcollection "tvshows"
                    let showCollection = userDocRef.collection("tvshows")
                    let col = try await showCollection.whereField("name", isEqualTo: show.name).getDocuments()
                    if !col.isEmpty
                    {
                        for showRef in col.documents{
                            let data2 = showRef.data()
                            let curShowName = data2["name"] as? String
                            if(show.name == curShowName)
                            {
                                isAdded = true
                                
                            }
                        }
                    }
                    else{
                        print("Its empty ")
                    }
                }
            }
        }
        catch{
            print(String(describing: error))
        }
        print("we are at the very end")
        print(isAdded)
        return isAdded
    }
    
    
    func addShowToList(email:String, show: TVShowSelected) async
    {
        countEps(show: show)
        let database = Firestore.firestore()
        let userCollection = database.collection("Users")
        do{
            let querySnapshot = try await userCollection.whereField("email", isEqualTo: email.lowercased()).getDocuments()
            
            //meaning something IS there
            if !querySnapshot.isEmpty{
                for document in querySnapshot.documents{
                    let id = document.documentID
                    let userDocRef = userCollection.document(id)
                    // Access the subcollection "tvshows"
                    let showCollection = userDocRef.collection("tvshows")
                    let col = try await showCollection.whereField("name", isEqualTo: show.name)
                        .getDocuments()
                    if col.isEmpty
                    {
                        try await showCollection.addDocument(data: [
                            "name": show.name,
                            "id": show.id,
                            "curepnum": 1,
                            "curseason": 1,
                            "epsInSeason": epsInSeason,
                            "timestamp": Timestamp()
                        ])
                    }
                }
            }
        }
        catch{
            print("Something Happened")
        }
    }
    
    func countEps(show: TVShowSelected){
        var curCount = 0
        for ep in show.episodes{
            if ep.season == 1{
                curCount += 1
            }
        }
        epsInSeason = curCount
    }
    
    
    func updateEP(email:String, show: FirebaseTvShow, epBool: Bool) async{
        let database = Firestore.firestore()
        let userCollection = database.collection("Users")
        do{
            let querySnapshot = try await userCollection.whereField("email", isEqualTo: email.lowercased()).getDocuments()
            
            //meaning something IS there
            if !querySnapshot.isEmpty{
                for document in querySnapshot.documents{
                    let id = document.documentID
                    let userDocRef = userCollection.document(id)
                    // Access the subcollection "tvshows"
                    let showCollection = userDocRef.collection("tvshows")
                    let col = try await showCollection.whereField("name", isEqualTo: show.name)
                        .getDocuments()

                    if !col.isEmpty
                    {
                        for showDoc in col.documents{
                            let docId = showDoc.documentID
                            let showRef = showCollection.document(docId)
                            let data = showDoc.data()
                            if let epCount = data["epsInSeason"] as? Int{
                                print(epCount)
                                if let curEpOn = data["curepnum"] as? Int{
                                    print(curEpOn)
                                    if epBool == true{
                                        if epCount >= curEpOn + 1{
                                            print("Im in")
                                            showRef.updateData(["curepnum": curEpOn + 1]) { error in
                                                if let error = error {
                                                    print("Error updating document: \(error)")
                                                }
                                            }
                                        }
                                        else{
                                            showRef.updateData(["curepnum": 1]) { error in
                                                if let error = error {
                                                    print("Error updating document: \(error)")
                                                }
                                            }
                                            showRef.updateData(["curseason": show.curSeason + 1]) { error in
                                                if let error = error {
                                                    print("Error updating document: \(error)")
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        if 1 <= curEpOn - 1{
                                            showRef.updateData(["curepnum": curEpOn - 1]) { error in
                                                if let error = error {
                                                    print("Error updating document: \(error)")
                                                }
                                            }
                                        }
                                        else{
                                            if show.curSeason > 1{
                    
                                                showRef.updateData(["curseason": show.curSeason - 1]) { error in
                                                    if let error = error {
                                                        print("Error updating document: \(error)")
                                                    }
                                                }
                                                showRef.updateData(["curseason": show.maxEpCurSeason]) { error in
                                                    if let error = error {
                                                        print("Error updating document: \(error)")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
        }
        
        catch{
            print(String(describing: error))
        }
    }
    
    func deleteShow(email:String, show:FirebaseTvShow ) async{
        let database = Firestore.firestore()
        let userCollection = database.collection("Users")
        do{
            let querySnapshot = try await userCollection.whereField("email", isEqualTo: email.lowercased()).getDocuments()
            
            //meaning something IS there
            if !querySnapshot.isEmpty{
                for document in querySnapshot.documents{
                    let id = document.documentID
                    let userDocRef = userCollection.document(id)
                    // Access the subcollection "tvshows"
                    let showCollection = userDocRef.collection("tvshows")
                    let col = try await showCollection.whereField("name", isEqualTo: show.name)
                        .getDocuments()
                    
                    if !col.isEmpty
                    {
                        for showDoc in col.documents{
                            let docId = showDoc.documentID
                            let data = showDoc.data()
                            let docRef = userDocRef.collection("tvshows").document(docId)
                            docRef.delete { error in
                                if let error = error{
                                    print(error.localizedDescription)
                                }
                                
                            }
                        }
                    }
                }
            }
        }
        catch{
            print(String(describing: error))
        }
    }
    
    func signUp(email: String, password: String) async{
        let database = Firestore.firestore()
        let userCollection = database.collection("Users")
        do{
            let newUserDocument = userCollection.document()
            try await Auth.auth().createUser(withEmail: email, password: password)

        }
        catch{
            print(String(describing: error))
        }
    }
    
    func getFollowers(email: String) async -> [String]{
        var following: [String] = []
        let database = Firestore.firestore()
        let userCollection = database.collection("Users")
        do{
            let querySnapshot = try await userCollection.whereField("email", isEqualTo: email.lowercased()).getDocuments()
            
            //meaning something IS there
            if !querySnapshot.isEmpty{
                for document in querySnapshot.documents{
                    let id = document.documentID
                    let userDocRef = userCollection.document(id)
                    // Access the subcollection "tvshows"
                    let followerCollection = userDocRef.collection("following")
                    let col = try await followerCollection.getDocuments()
                    
                    if !col.isEmpty{
                        for followingDoc in col.documents{
                            let data = followingDoc.data()
                            if let userName = data["userEmail"] as? String{
                                following.append(userName)
                            }
                            
                        }
                    }
                }
            }
        }
        catch{
            print(String(describing: error))
        }
        
        return following
    }
    
    func addUser(email: String) async {
        let db = Firestore.firestore()
        let userCollection = db.collection("Users")
        
        do{
            let docRef = try await userCollection.addDocument(data: [
                "email": email,
                "followercount": 0,
            ])
            
            let docId = docRef.documentID
            let newUserCollection = db.collection("Users").document(docId).collection("tvshows")
        }
        catch{
           print(String(describing: error))
        }
    }
    
    func signOut() async{
        print("HELLO")
        do{
            try Auth.auth().signOut()
        }
        catch{
            print("uh guys hes right behind me isnt he")
            print(String(describing: error))
        }
    }
    
}
