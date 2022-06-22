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
    private var portfolio: (Float,Float) = (0.0,0.0)
    
    convenience init(exchange: String = "", data: (String,(Float,AssetsBalances?,Exchanges?))? = nil ) {
        self.init()
        
        self.exchange = exchange
        self.data = data
        if let data = data {portfolio.0 = data.1.0}
    }
    
    private func lookupAsset(_ key: String ) -> String { return key == "XBT" ? "BTC" : key }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //if let exchange = exchange, let data = data, let tabledata = data.1.1 {
        if let exchange = exchange{
            self.title = exchange
            var temp: [(String,Float,Float)] = []
            self.tabledata.append(("Asset", "Total", "\(globalLocalCurrency)"))
            if let data = data, let tabledata = data.1.1 {
                for d in tabledata { temp.append((lookupAsset(d.key), d.value.0, d.value.1)) }
                for d in temp.sorted(by: {$0.2 > $1.2}) { self.tabledata.append((d.0, "\(d.1)".toCurrency, "\(d.2)".toCurrency)) }
            }
            let table = GenericTableView(DetailTableViewCell.self, self.tabledata,self.view.frame.height,nil ) {
                (action,index,cell,data) in
                if action == .ConfigureCell, index.row == 0 { cell?.rePaintHeader() }
                return false
            }
            
            getStackView().addArrangedSubview(createSummaryView())
            getStackView().addArrangedSubview( UIView(10) )
            getStackView().addArrangedSubview(table)
            
            self.navigationItem.rightBarButtonItem  =  UIBarButtonItem(image: UIImage(named: "icon.key"), style: .plain, target: self, action: #selector(openCredentials))
        }
    }
    
    @objc private func openCredentials() {
        self.navigationController?.pushViewController(CredentialViewController(exchange: exchange!), animated: true)
    }
    
    
    private func createSummaryView() -> UIView {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale.current
        let v = UIView(60)
        let caption = UILabel( "Portfolio", .left, 16, .medium, .lightGray)
        let value   = UILabel( "\(globalLocalCurrency) "+"\(portfolio.0)".toCurrency,       .left, 16, .medium, .white)
        let date = UILabel("\(formatter.string(from: Date()))", .left, 10, .light, .defaultLineColor)
        v.addSubview(caption)
        v.addSubview(value)
        v.addSubview(date)
        v.roundCorners(5.0, .defaultLineColor, 0.5)
        
        caption.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 10.0).isActive = true
        value.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -10.0).isActive = true
        date.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -10.0).isActive = true
        
        caption.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        value.centerYAnchor.constraint(equalTo: v.centerYAnchor  ).isActive = true
        date.bottomAnchor.constraint(equalTo: value.topAnchor  ).isActive = true
        
        return v
    }
}
