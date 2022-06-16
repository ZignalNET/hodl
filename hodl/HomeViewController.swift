//
//  HomeViewController.swift
//  Part of hodl
//
//  Created by Emmanuel Adigun on 2022/06/09.
//

import UIKit

class HomeViewController: BaseScrollViewController {
    private var localFiat: String = globalLocalCurrency
    private var chartView: HodlPieChartView?
    private var summaryTableView: GenericTableView<Any, SummaryTableViewCell>!
    
    private var summaryTableModel: [(String,(Float,AssetsBalances?,Exchanges?))] = fetchDefaultExchangeData() //[("",(0,nil))]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Hodl"
        chartView = HodlPieChartView(localFiat: localFiat)
        createSummaryTable()
        getStackView().addArrangedSubview(chartView!)
        getStackView().addArrangedSubview( UIView(10) )
        getStackView().addArrangedSubview(createSummaryHeader())
        getStackView().addArrangedSubview( UIView(10) )
        getStackView().addArrangedSubview( summaryTableView )
        
        registerNotifications()
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(forName: .refreshExchangeDataDetails, object: nil, queue: nil) { [weak self] (notification) in
            guard let this = self else { return }
            if let assetsbalances = notification.object as? [String:(Float,AssetsBalances?,Exchanges?)] {
                this.summaryTableModel = []
                for assetsbalance in assetsbalances {
                    let exchange = assetsbalance.key
                    let details  = assetsbalance.value
                    this.summaryTableModel.append((exchange, details))
                }
                this.summaryTableView.reloadWithData(models: this.summaryTableModel.sorted(by: {$0.1.0 > $1.1.0}))
            }
        }
    }
    
    
    private func createSummaryTable() {
        summaryTableView = GenericTableView(SummaryTableViewCell.self, summaryTableModel.sorted(by: {$0.1.0 > $1.1.0}),200,nil ) {
            (action,index,cell,data) in
            if action == .SelectCell {
                if let data = data as? (String,(Float,AssetsBalances?,Exchanges?)) {
                    if !isConnectedToInternet() { UIAlertController.presentMessage("Your phone appears to have lost active internet connection.", "Error", nil) }
                    else if let _ = data.1.1 {
                        self.navigationController?.pushViewController(DetailViewController(exchange:data.0,data:data), animated: true)
                    }
                    else {
                        guard let eo = ExchangeObjects[data.0.uppercased()] else { return false }
                        if eo.hasApiKeys() != nil { self.navigationController?.pushViewController(DetailViewController(exchange:data.0,data:data), animated: true) }
                        else { self.navigationController?.pushViewController(CredentialViewController(exchange:data.0), animated: true) }
                    }
                }
            }
            return false
        }
    }
    
    private func createSummaryHeader() -> UIView {
        let v = UIView()
        let a = UILabel( "Exchange", .left, 16, .medium, .white)
        let b = UILabel( "Total", .left, 16, .medium, .white)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 25).isActive = true
        v.addSubview(a)
        v.addSubview(b)
        
        a.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 10.0).isActive = true
        b.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -10.0).isActive = true
        
        a.topAnchor.constraint(equalTo: v.topAnchor, constant: 5.0).isActive = true
        b.topAnchor.constraint(equalTo: v.topAnchor, constant: 5.0).isActive = true
       
        return v
    }
}



