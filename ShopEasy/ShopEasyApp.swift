//
//  ShopEasyApp.swift
//  ShopEasy
//
//  Created by Aasrith Mareddy on 05/05/25.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct ShopEasyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var cartManager = CartManager()
    @StateObject private var orderManager = OrderManager()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(cartManager)
                .environmentObject(orderManager)
        }
    }
}
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                    launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

func application(_ app: UIApplication,
                 open url: URL,
                 options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
  return GIDSignIn.sharedInstance.handle(url)
}
