//
//  AppDelegate.swift
//  unicon
//
//  Created by Imajin Kawabe on 2018/06/16.
//  Copyright © 2018年 Imajin Kawabe. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FacebookCore
import FacebookLogin
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, LoginButtonDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        AppDelegate.configureInitialRootViewController(for: window)
        
        IQKeyboardManager.shared.enable = true
        
        UINavigationBar.appearance().barTintColor = UIColor.hex(hex: "FFFCF2", alpha: 1.0)
        UINavigationBar.appearance().shadowImage = UIImage()
        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return SDKApplicationDelegate.shared.application(application,
                                                             open: url,
                                                             sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                             annotation: [:])
    }
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case let LoginResult.failed(error):
            // いい感じのエラー処理
            break
        case let LoginResult.success(grantedPermissions, declinedPermissions, token):
            let credential = FacebookAuthProvider.credential(withAccessToken: token.authenticationToken)
            // Firebaseにcredentialを渡してlogin
            Auth.auth().signInAndRetrieveData(with: credential) { (fireUser, fireError) in
                if let error = fireError {
                    print(error.localizedDescription)
                    return
                } else {
                    AppDelegate.configureInitialRootViewController(for: self.window)
                }
                
            }
        default:
            break
        }
        
    }
    // 6. loginButtonDidLogOutを追加
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        AppDelegate.configureInitialRootViewController(for: self.window)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    // Handle logged in user / new user
    static func configureInitialRootViewController(for window: UIWindow?) {
        
        let initialViewController: UIViewController
//
//        if UserDefaults.standard.object(forKey: "welcomed") == nil {
//
//            print("FOR THE FIRST TIME")
//            initialViewController = UIStoryboard.initialViewController(for: .welcome)
//
//        }
        
        let defaults = UserDefaults.standard
        
        if Auth.auth().currentUser != nil, let userData = defaults.object(forKey: Constants.UserDefaults.currentUser) as? Data, let user = NSKeyedUnarchiver.unarchiveObject(with: userData) as? User {
            print("既存ユーザー")
            // set current user
            User.setCurrent(user)
            // set current team if any
            if let teamData = defaults.object(forKey: Constants.UserDefaults.currentTeam) as? Data, let team = NSKeyedUnarchiver.unarchiveObject(with: teamData) as? Team {
                Team.setCurrent(team)
            }
            initialViewController = UIStoryboard.initialViewController(for: .main)
        } else {
            print("新規ユーザー")
            initialViewController = UIStoryboard.initialViewController(for: .onboard)
        }
        
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
    }


}

