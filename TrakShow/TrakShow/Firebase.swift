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
    
    
    
    func performGoogleSignIn() async -> Bool{
        
        enum SignInError: Error{
            case idTokenMissing
        }
        let signInConfig = GIDConfiguration(clientID: FirebaseApp.app()?.options.clientID ?? "")
        
        GIDSignIn.sharedInstance.configuration = signInConfig
        
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = await windowScene.windows.first,
                      let rootViewController = await window.rootViewController else{
                    print("There is not root view controller")
                    return false
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
            }
            catch{
                print(error.localizedDescription)
            }
            
            return true
        }
        catch{
            print(error.localizedDescription)
            return false
        }
    }
    
    func getAllFirebaseUsers() async
    {
        let db = Firestore.firestore()
        let userCollection = db.collection("Users")
        do
        {
            let querySnapshot = try await userCollection.getDocuments()
            for document in querySnapshot.documents
            {
                if let email = document.data()["email"] as? String
                {
                    print("WE BACK EMAIL: \(email)")
                }
            }
        }
        catch{
            print(error)
        }
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
    
}
