//
//  OrderViewController.swift
//  hodl
//
//  Created by Emmanuel Adigun on 2022/06/17.
//

import UIKit

class OrderViewController: BaseScrollViewController {
    private var pendingOrders: [String:(Int,PendingOrders)] = [:]
    convenience init(_ pendingOrders: [String:(Int,PendingOrders)] = [:] ) {
        self.init()
        self.pendingOrders = pendingOrders
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Pending Orders"
        for pendingOrder in pendingOrders {
            getStackView().addArrangedSubview(createOrderView( (pendingOrder.key,pendingOrder.value.1) ))
            getStackView().addArrangedSubview(UIView(10))
        }
        
        
    }
    

    private func createOrderView(_ exchange: (String,PendingOrders) ) -> UIView {
        let wrapper = UIView(60)
        let label   = UILabel( exchange.0.capitalized, .left, 16, .medium, .lightGray)
        let image   = UIImageView(exchange.0.lowercased(), 15.0, 1.0, .clear)
        let badge   = BadgeView("\(exchange.1.count)",.white,.tableCellColor, 40, 40,.white.withAlphaComponent(0.2), 16)
        
        wrapper.addSubview(label)
        wrapper.addSubview(image)
        wrapper.addSubview(badge)
        
        wrapper.addLine()
        
        image.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 10).isActive = true
        label.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 5).isActive = true
        
        image.widthAnchor.constraint(equalToConstant: 30).isActive = true
        image.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        badge.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -10).isActive = true
        
        image.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor).isActive = true
        badge.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor).isActive = true
        
        wrapper.addTapGestureRecognizer {
            self.navigationController?.pushViewController(OrderDetailViewController(exchange), animated: true)
        }
        
        return wrapper
    }

}
