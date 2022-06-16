//
//  UIAlertController.swift
//  Part of my local repo
//
//  Created by Emmanuel Adigun on 2021/07/05.
//  Copyright © 2021. All rights reserved.
//

import UIKit
typealias UIAlertConfirmAction  = (Bool) -> Void
typealias UIAlertNofifyAction   = () -> Void
typealias UIAlertActionCallback = (UIAlertAction) -> Void

extension UIAlertController {
    
    static func notify(_ message: String = "",  _ callback: UIAlertNofifyAction? = nil) {
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: { _ in
            DispatchQueue.main.async {
                alertWindow.isHidden = true
                callback?()
            }
        }))
        
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
       
    }
    
    static func presentMessage(_ message: String = "", _ title: String = "" , _ callback: UIAlertActionCallback? = nil ) {
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler: { action in
            alertWindow.isHidden = true
            callback?(action)
        }))
        
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
       
    }
    
    static func confirm(_ title: String = "", _ message: String = "",  _ callback: UIAlertConfirmAction? = nil ) {
        
        let viewController = UIViewController()
        
        let options = ["OK":YES,"Cancel":NO]
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = viewController
        
        func alertControllerCallback(_ action: UIAlertAction) {
            DispatchQueue.main.async {
               alertWindow.isHidden = true
               if let x = action.title {
                   callback?( options[x]! )
               }
            }
        }
        
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler:  alertControllerCallback))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:  alertControllerCallback))
        
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
}

