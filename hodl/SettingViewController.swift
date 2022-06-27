//
//  SettingViewController.swift
//  hodl
//
//  Created by Emmanuel Adigun on 2022/06/16.
//

import UIKit

class SettingViewController: BaseScrollViewController {
    
    private var exchangeTableView: GenericTableView<Any, ExchangeTableViewCell>!
    private var currencyTableView: GenericTableView<Any, CurrencyTableViewCell>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title      = "Settings"
        exchangeTableView   = createTable(ExchangeTableViewCell.self, []   ,180,tableCallBack)
        currencyTableView   = createTable(CurrencyTableViewCell.self, []   ,200,tableCallBack)
    
        getStackView().addArrangedSubview(UILabel( "  Connected Exchanges", .left, 16, .medium, .mediumSeaGreenColor))
        getStackView().addArrangedSubview(UIView(10))
        getStackView().addArrangedSubview(exchangeTableView)
        getStackView().addArrangedSubview(UIView(60))
        getStackView().addArrangedSubview(UILabel( "  Local Currency", .left, 16, .medium, .mediumSeaGreenColor))
        getStackView().addArrangedSubview(UIView(10))
        getStackView().addArrangedSubview(currencyTableView)
        
        registerNotifications()
        reloadData()
    }
    
    private func reloadData() {
        exchangeTableView.reloadWithData(models: fetchExchangeData())
        currencyTableView.reloadWithData(models: fetchCurrencyData())
    }
    
    private func fetchExchangeData() -> [(String,Int)] {
        var data: [(String,Int)] = []
        for exchange in fetchExchanges() {
            if let name = exchange["name"] as? String, let eo = ExchangeObjects[name.uppercased()]  {
                data.append((name,eo.hasApiKeys() != nil ? 1 : 0))
            }
        }
        return data.sorted(by: { $0.1 > $1.1 })
    }
    
    private func fetchCurrencyData() -> [(String,Int)] {
        let currencies = ["EUR","JPY","KRW","ZAR","NGN","GBP","AUD","CAD"]
        var data: [(String,Int)] = []
        for currency in currencies {
            data.append((currency,currency == globalLocalCurrency ? 1 : 0 ))
        }
        return data.sorted(by: { $0.1 > $1.1 })
    }
    
    
    private func tableCallBack<T, Cell: UITableViewCell>( _ action: GenericTableSwipeMenuAction, _ index: IndexPath,_ cell: Cell?, _ data: T?, _ table: GenericTableView<T,Cell>) -> Bool {
        if let cell = cell {
            if action == .SelectCell {
                if cell.isKind(of: CurrencyTableViewCell.self) {
                    let currency = data as! (String,Int)
                    globalLocalCurrency = currency.0
                    currencyTableView.reloadWithData(models: fetchCurrencyData())
                    UIAlertController.presentMessage("Your local currency has now been changed to \(currency.0). Please refresh.", "Info")
                }
                else if cell.isKind(of: ExchangeTableViewCell.self) {
                    let b = data as! (String,Int)
                    table.reloadData()
                    self.navigationController?.pushViewController(CredentialViewController(exchange:b.0), animated: true)
                }
            }
        }
        return false
    }
    
    private func createTable<T, Cell: UITableViewCell>(_ tableCellType: Cell.Type, _ data: [T], _ height: CGFloat = 90.0, _ callback: GenericTableView<T, Cell>.Callback? = nil) -> GenericTableView<T, Cell> {
        return GenericTableView(tableCellType, data,height,nil){
            (action,index,cell,data,table) in
            if let callback = callback { return callback(action,index,cell,data,table) }
            return false
        }
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(forName: .refreshGenericTableViewData, object: nil, queue: nil) { [weak self] (notification) in
            guard let this = self else { return }
            this.exchangeTableView.reloadWithData(models: this.fetchExchangeData())
        }
    }

}
