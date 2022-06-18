//
//  DetailViewController.swift
//  hodl
//
//  Created by Emmanuel Adigun on 2022/06/10.
//

import UIKit

class DetailViewController: BaseScrollViewController {
    private var exchange: String?
    private var data: (String,(Float,AssetsBalances?,Exchanges?))?
    private var tabledata: [(String,String,String)] = []
    convenience init(exchange: String = "", data: (String,(Float,AssetsBalances?,Exchanges?))? = nil ) {
        self.init()
        
        self.exchange = exchange
        self.data = data
    }
    
    private func lookupAsset(_ key: String ) -> String { return key == "XBT" ? "BTC" : key }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //if let exchange = exchange, let data = data, let tabledata = data.1.1 {
        if let exchange = exchange {
            self.title = exchange
            var temp: [(String,Float,Float)] = []
            self.tabledata.append(("Asset", "Total", "ZAR"))
            if let data = data, let tabledata = data.1.1 {
                for d in tabledata { temp.append((lookupAsset(d.key), d.value.0, d.value.1)) }
                for d in temp.sorted(by: {$0.2 > $1.2}) { self.tabledata.append((d.0, "\(d.1)".toCurrency, "\(d.2)".toCurrency)) }
            }
            let table = GenericTableView(DetailTableViewCell.self, self.tabledata,self.view.frame.height,nil ) {
                (action,index,cell,data) in
                if action == .ConfigureCell, index.row == 0 { cell?.rePaintHeader() }
                return false
            }
            getStackView().addArrangedSubview(table)
            
            self.navigationItem.rightBarButtonItem  =  UIBarButtonItem(image: UIImage(named: "icon.key"), style: .plain, target: self, action: #selector(openCredentials))
        }
    }
    
    @objc private func openCredentials() {
        self.navigationController?.pushViewController(CredentialViewController(exchange: exchange!), animated: true)
    }
    
}
