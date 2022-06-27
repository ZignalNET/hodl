//
//  LaunchViewController.swift
//  hodl
//
//  Created by Emmanuel Adigun on 2022/06/26.
//

import UIKit

class LaunchViewController: UIViewController {
    
    let imgView = UIImageView("icon.launch")

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = ""
        view.backgroundColor = .defaultBackgroundColor1
        view.addSubview(imgView)
        
        imgView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        imgView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        imgView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imgView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        imgView.roundCorners(50, .defaultLineColor, 0.5)
        registerNotifications()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(forName: .refreshExchangeDataDetails, object: nil, queue: nil) { [weak self] (notification) in
            guard let this = self else { return }
            this.dismissViewController()
        }
    }

}
