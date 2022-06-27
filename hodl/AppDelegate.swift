//
//  AppDelegate.swift
//  Part of hodl
//
//  Created by Emmanuel Adigun on 2022/06/09.
//

import UIKit
import LiteDB

let HodlDb    = Database.sharedInstance("hodl.sqlite3")
//let HodlTimer = Timer("HODL", 60, onTimerExchangeCallback)

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        initModels()
        startApp(HomeViewController())
        return true
    }

    private func startApp(_ viewController: UIViewController  ) {
        window = window ?? UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = BaseNavigationController( rootViewController: viewController )
        window?.makeKeyAndVisible()
        
        if fetchConnectedExchanges().count == 0 {
            viewController.navigationController?.pushViewController(SettingViewController(), animated: true)
        }
        else {
            viewController.navigationController?.pushViewController(LaunchViewController(), animated: true)
        }
    }
    
}

