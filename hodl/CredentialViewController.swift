//
//  CredentialViewController.swift
//  hodl
//
//  Created by Emmanuel Adigun on 2022/06/12.
//

import UIKit

class CredentialViewController: BaseScrollViewController {
    private var exchange: String?
    private var apiKey: UITextField = UITextField()
    private var apiSecret: UITextField = UITextField()
    
    convenience init(exchange: String = "" ) {
        self.init()
        
        self.exchange = exchange
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let exchange = exchange{
            self.title = exchange
            getStackView().addArrangedSubview( UIView(5) )
            getStackView().addArrangedSubview( createCaption() )
            getStackView().addArrangedSubview( UIView(10) )
            getStackView().addArrangedSubview( UIView("Key", "Enter API Key", apiKey)  )
            getStackView().addArrangedSubview( UIView(10) )
            getStackView().addArrangedSubview( UIView("Secret", "Enter API Secret", apiSecret)  )
           
            createSaveButton()
            if let data: ApiKey = KeyChainService.retrieveKey(exchange.uppercased()) {
                apiKey.text    = data.key
                apiSecret.text = data.secret
            }
        }
    }
    
    func createSaveButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(onSaveButton))
    }
    
    @objc func onSaveButton() {
        guard let key = apiKey.text, !key.isEmpty  else {
            UIAlertController.presentMessage("API Key Field cannot be blank", "Error")
            return
        }
        guard let secret = apiSecret.text, !secret.isEmpty  else {
            UIAlertController.presentMessage("API Secret Field cannot be blank", "Error")
            return
        }
        guard let exchange = exchange else { return }
        guard let eo = ExchangeObjects[exchange.uppercased()] else { return }
        let apikey = ApiKey(exchange.uppercased(), key, secret)
        if apikey.isValid(eo) {
            HodlTimer.suspend()
            if KeyChainService.saveKey(exchange.uppercased(), apikey) {
                UIAlertController.presentMessage("Credentials successfully saved", "Success") { action in
                    self.dismissViewController()
                }
            }
            HodlTimer.resume()
        }
        else {
            UIAlertController.presentMessage("API credentials are not valid", "Error")
        }
    }
    
    private func createCaption() -> UIView {
        let v = UIView(20)
        let caption = UILabel( "Credentials", .left, 16, .medium, .lightGray)
        let i = UIImageView("icon.key")
        v.addSubview(i)
        v.addSubview(caption)
        i.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        i.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 8).isActive = true
        caption.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        caption.leadingAnchor.constraint(equalTo: i.trailingAnchor, constant: 2).isActive = true
        return v
    }
    
}

