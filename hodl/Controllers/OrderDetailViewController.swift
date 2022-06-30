//
//  OrderDetailViewController.swift
//  hodl
//
//  Created by Emmanuel Adigun on 2022/06/22.
//

import UIKit

class OrderDetailViewController: BaseScrollViewController {
    private var pendingOrder: (String,PendingOrders)?
    private var pendingOrderTableView: GenericTableView<Any, PendingOrderTableViewCell>!
    convenience init(_ pendingOrder: (String,PendingOrders)? ) {
        self.init()
        if let pendingOrder = pendingOrder {
            self.pendingOrder = pendingOrder
            self.title = pendingOrder.0
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createTable()
        getStackView().addArrangedSubview(UILabel( "  Pending Orders", .left, 16, .medium, .defaultAppStrongColor))
        getStackView().addArrangedSubview(pendingOrderTableView)
    }
    
    private func createTable() {
        if let pendingOrder = pendingOrder {
            var order = pendingOrder.1
            order.insert(("HEADER","Pair","","","Date"), at: 0)  //table header ...
            pendingOrderTableView = GenericTableView(PendingOrderTableViewCell.self, order,400,nil ) {
                (action,index,cell,data,table) in
                return false
            }
        }
    }
}


