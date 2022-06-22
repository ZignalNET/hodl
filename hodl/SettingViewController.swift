//
//  SettingViewController.swift
//  hodl
//
//  Created by Emmanuel Adigun on 2022/06/16.
//

import UIKit

class SettingViewController: BaseScrollViewController {
    
    private let currencies = ["ZAR","NGN"]
    private var table: GenericTableView<Any,SettingTableViewCell>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Settings"
        table = GenericTableView(SettingTableViewCell.self, self.currencies,300,nil ) {
            (action,index,cell,data) in
            let currency = data as! String
            if action == .SelectCell {
                globalLocalCurrency = currency
                self.table.reloadData()
                UIAlertController.presentMessage("Your local currency has now been changed to \(currency)", "Info")
            }
            return false
        }
        
        getStackView().addArrangedSubview(createCaption())
        getStackView().addArrangedSubview(UIView(10))
        getStackView().addArrangedSubview(table)
    }
    
    private func createCaption() -> UIView {
        let v = UIView(20)
        let caption = UILabel( "Local Currency", .left, 16, .medium, .lightGray)
        let i = UIImageView("icon.currency")
        v.addSubview(i)
        v.addSubview(caption)
        i.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        i.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 8).isActive = true
        caption.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        caption.leadingAnchor.constraint(equalTo: i.trailingAnchor, constant: 2).isActive = true
        return v
    }

}
