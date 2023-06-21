//
//  AppDelegate.swift
//  Let's Chat
//
//  Created by DUIUX-01 on 23/03/23.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UNUserNotificationCenter.current().delegate = self
        
        
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
        
        let user = Auth.auth().currentUser
        if user != nil {
            
            let pushManager = PushNotificationManager(userID: Auth.auth().currentUser?.uid ?? "")
                pushManager.registerForPushNotifications()
            
            let st = UIStoryboard(name: "Main", bundle: nil)
            let homePageTabBarController = st.instantiateViewController(withIdentifier: "HomePageTabBarController") as! HomePageTabBarController
            let rootNC = UINavigationController(rootViewController: homePageTabBarController)

            self.window!.rootViewController = rootNC
            
            
            if let user = Auth.auth().currentUser{
                let onlineRef = Database.database().reference(withPath: "Online")
                let child = onlineRef.child(user.uid)
                child.setValue("")
            }
        }
        
        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
    
 
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("--------------Foreground-----------------")
        if let user = Auth.auth().currentUser{
            let onlineRef = Database.database().reference(withPath: "Online")
            let child = onlineRef.child(user.uid)
            child.setValue([""])
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("--------------Background-----------------")
        if let user = Auth.auth().currentUser{
            let onlineRef = Database.database().reference(withPath: "Online").child(user.uid)
            onlineRef.removeValue()
        }
    }
    
}
extension AppDelegate: UNUserNotificationCenterDelegate {
  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // ...

    // Print full message.
    print(userInfo)

    // Change this to your preferred presentation option
    return [[.alert, .sound]]
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse) async {
    let userInfo = response.notification.request.content.userInfo

    // ...

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print full message.
    print(userInfo)
  }
}
