//
//  BaseNavigationController.swift
//  Part of my local repo
//
//  Created by Emmanuel Adigun on 2021/05/11.
//  Copyright © 2021. All rights reserved.
//


import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.isTranslucent = true
        self.navigationBar.tintColor = .white
        //self.navigationBar.barTintColor = .white
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationBar.setBackgroundImage(UIColor.colorForNavBar(color: .defaultBackgroundColor1), for: .default)
        self.modalPresentationStyle = .fullScreen
    }

}

extension BaseNavigationController {
   override var preferredStatusBarStyle: UIStatusBarStyle {
        //set color of status bar showing carrier, time, and battery on top
        return .lightContent
    }
}
