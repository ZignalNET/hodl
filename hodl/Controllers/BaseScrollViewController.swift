//
//  BaseViewController.swift
//  Part of my local repo
//
//  Created by Emmanuel Adigun on 2021/05/11.
//  Copyright © 2021. All rights reserved.
//

import UIKit

class BaseScrollViewController: UIViewController {
    private let refreshControl = UIRefreshControl()
    private let contentView: UIView = UIView()
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isUserInteractionEnabled = true
        return scrollView
    }()

    private let stackViewContainer: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 0 //10
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        
        view.distribution = .fillProportionally
        view.alignment = .fill
        return view
    }()
    
    private let toolbar: UIView = {
        let toolbar = UIView()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.backgroundColor = .defaultBackgroundColor1
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        layoutViews()
        getStackView().addArrangedSubview(UIView(20.0))
        
        //if this is not root viewcontroller; create done button
        if let count = self.navigationController?.viewControllers.count, count > 1 {
            createDoneButton()
        }
        
        
        //Pull to refresh ..
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to reload data ...", attributes:[NSAttributedString.Key.foregroundColor:UIColor.white])
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        scrollView.addSubview(refreshControl)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        //set color of status bar showing carrier, time, and battery on top
        return .lightContent
    }
    
    @objc func refresh(_ sender: Any) {
        //  your code to reload tableView
        self.onRefreshControl(sender)
        refreshControl.endRefreshing()
    }
    
    func onRefreshControl( _ sender: Any ) {
        
    }
    
    private func createToolBar() {
        view.addSubview(toolbar)
        toolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        toolbar.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
    }
    
    private func createContentView() {
        view.addSubview(contentView)
        contentView.backgroundColor = .defaultBackgroundColor1
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        //contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        //contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    private func layoutViews() {
        //createToolBar()
        createContentView()
        
        contentView.addSubview(scrollView)
        scrollView.addSubview(stackViewContainer)

        scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 0).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: 0).isActive = true
        scrollView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        stackViewContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackViewContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        stackViewContainer.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackViewContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        // Scrolling, plonkeR!!
        stackViewContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        //top spacing
        //stackViewContainer.addArrangedSubview(UIView(10))
    }
    
    func addCustomView(_ customView: UIView ) {
        stackViewContainer.addArrangedSubview(customView)
    }

    func getStackView() -> UIStackView { return stackViewContainer }
    
    func getContentView() -> UIView { return contentView }
    
    func createDoneButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(dismissViewController))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deRegisterKeyboardNotifications()
    }
    
    func registerKeyboardNotifications() {
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
            // call the 'keyboardWillHide' function when the view controlelr receive notification that keyboard is going to be hidden
          NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    func deRegisterKeyboardNotifications() {
        //NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        //NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, dont do anything
            //print("if keyboard size is not available for some reason, dont do anything")
            return
        }

        // move the root view up by the distance of keyboard height
        var offset: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            offset = self.view.safeAreaInsets.top
        }
        //offset = max(offset,self.stackViewContainer.frame.height/2)
        let height = max(keyboardSize.height,self.stackViewContainer.frame.height/2)
        self.stackViewContainer.frame.origin.y = 0 - height + offset
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        // move back the root view origin to zero
        self.stackViewContainer.frame.origin.y = 0
    }
    
}

