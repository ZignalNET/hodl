//
//  UIViewController.swift
//  Part of my local repo
//
//  Created by Emmanuel Adigun on 2021/05/23.
//  Copyright © 2021. All rights reserved.
//

import UIKit


extension UIViewController {
    func presentViewController(_ viewController: UIViewController, _ data: Any? = nil ) {
        let navController = BaseNavigationController(rootViewController: viewController)
        self.present(navController, animated: true, completion: {
            
        })
    }
    
    func createCancelButton() {
        self.navigationItem.leftBarButtonItem  =  UIBarButtonItem(image: UIImage(named: "icon.back"), style: .plain, target: self, action: #selector(dismissViewController))
    }
    
    @objc func dismissViewController() {
        //self.dismiss(animated: false, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func handleNotifications(notification: NSNotification) {
        
        
    }
    
}


