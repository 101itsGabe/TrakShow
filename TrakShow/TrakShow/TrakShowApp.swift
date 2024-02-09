//
//  TrakShowApp.swift
//  TrakShow
//
//  Created by Gabriel Mannheimer on 2/7/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      let userDefault = UserDefaults.standard
          let launchedBefore = UserDefaults.standard.bool(forKey: "usersignedin")
          let providerFactory = AppCheckDebugProviderFactory()
          AppCheck.setAppCheckProviderFactory(providerFactory)
      FirebaseApp.configure()

    return true
  }
}

@main
struct TrakShowApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView(trakshowManager: TrakShowManager())
        }
    }
}
