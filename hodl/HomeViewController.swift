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
    private let orders = BadgeView("0", UIColor.white, UIColor.mediumSeaGreenColor)
    
    private var summaryTableModel: [(String,(Float,AssetsBalances?,Exchanges?))] = fetchDefaultExchangeData() //[("",(0,nil))]
    private var toastView: UILabel?
    
    override func onRefreshControl( _ sender: Any ) {
        refreshData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Hodl"
        chartView = HodlPieChartView(localFiat: localFiat)
        createSummaryTable()
        getStackView().addArrangedSubview(chartView!)
        getStackView().addArrangedSubview( UIView(10) )
        getStackView().addArrangedSubview(pendingOrderView())
        getStackView().addArrangedSubview( UIView(10) )
        getStackView().addArrangedSubview(createSummaryHeader())
        getStackView().addArrangedSubview( UIView(10) )
        getStackView().addArrangedSubview( summaryTableView )
        getStackView().addArrangedSubview( UIView(40) )
        registerNotifications()
        
        self.navigationItem.rightBarButtonItem  =  UIBarButtonItem(image: UIImage(named: "icon.extended"), style: .plain, target: self, action: #selector(openSettings))
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32)) // Create new button & set its frame
        button.setImage(#imageLiteral(resourceName: "icon.refresh"), for: .normal) // Assign an image
        button.addTarget(self, action: #selector(self.refreshData), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        refreshData()
    }
    
    @objc private func openSettings() {
        self.navigationController?.pushViewController(SettingViewController(), animated: true)
    }
    
    @objc private func refreshData() {
        guard isConnectedToInternet() else { UIAlertController.presentMessage("Your device appears to have lost active internet connection", "Error"); return }
        if let customView = self.navigationItem.leftBarButtonItem?.customView {
            let angle = CGAffineTransform(rotationAngle: 180 * .pi / 180)
            UIView.animate(withDuration: 7.0, animations: { customView.transform = angle }, completion: { (finished) in
                customView.transform = .identity
            })
        }
        toastView = self.showToast(message: "Loading your portfolio ...", font: .systemFont(ofSize: 14.0))
        fetchAllExchanges(globalLocalCurrency)
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
            
            if let pendingOrders = notification.userInfo as? [String:(Int,PendingOrders)] {
                let v = pendingOrders.map({$0.value.0}).reduce(0,+) //total orders on all exchanges
                this.orders.updateBadgeText("\(v)")
                for pendingOrder in pendingOrders {
                    print(pendingOrder)
                }
            }
            if let toastView = this.toastView {
                toastView.removeFromSuperview()
                this.toastView = nil
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
    
    private func pendingOrderView() -> UIView {
        func createInner() -> UIView {
            let v = UIView(35)
            let caption = UILabel( "Total", .left, 14, .medium, .lightGray)
            v.addSubview(caption)
            v.addSubview(orders)
            
            v.roundCorners(5.0, .defaultLineColor, 0.3)
            
            caption.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
            caption.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 10).isActive = true
            
            orders.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
            orders.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -5).isActive = true
            return v
        }
        
        let wrapper = UIView(80)
        let label   = UILabel( "Pending Orders", .left, 16, .medium, .white)
        let action  = UIImageView("icon.right")
        let v = createInner()
        
        wrapper.addSubview(label)
        wrapper.addSubview(action)
        wrapper.addSubview(v)
        
        label.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 5).isActive = true
        label.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 10).isActive = true
        
        action.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 5).isActive = true
        action.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -15).isActive = true
        
        v.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10).isActive = true
        v.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 10).isActive = true
        v.widthAnchor.constraint(equalTo: wrapper.widthAnchor, multiplier: 0.95).isActive = true
        
        wrapper.addTapGestureRecognizer {
            self.navigationController?.pushViewController(OrderViewController(), animated: true)
        }
        
        return wrapper
    }
    

}

