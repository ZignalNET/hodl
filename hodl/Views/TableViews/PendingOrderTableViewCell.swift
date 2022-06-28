//
//  PendingOrderTableViewCell.swift
//  hodl
//
//  Created by Emmanuel Adigun on 2022/06/22.
//

import UIKit

class PendingOrderTableViewCell: GenericTableViewCell {
    private let lblDate    = UILabel( "", .left,   12, .medium, .lightText)
    private let lblTime    = UILabel( "", .center, 10, .light, .defaultLineColor)
    private let lblPair    = UILabel( "", .left,   14, .medium, .white)
    private let lblQty     = UILabel( "", .right,  12, .medium, .defaultLineColor)
    private let lblPrice   = UILabel( "", .right,  12, .medium, .defaultAppStrongColor)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func commonInit() {
        backgroundColor = .clear
        roundCorners(5.0, .defaultLineColor, 0.2)
        addSubview(lblPair)
        addSubview(lblPrice)
        addSubview(lblQty)
        addSubview(lblDate)
        addSubview(lblTime)
    }
    
    override func onConfigureCell(cell: UITableViewCell, model: Any) {
        let b = model as! PendingOrder
        if b.0 == "HEADER" {
            _ = [ lblPair, lblPrice, lblQty, lblDate ].map({ $0.textColor = .lightText })
            lblDate.text  = "Date"
            lblPair.text  = "Pair"
            lblPrice.text = "Price"
            lblQty.text   = "Qty"
            roundCorners(5.0, .clear, 0.0)
        }
        else {
            let price = b.2
            let p = "\(price)".split{$0 == "."}
            var places: Int = 2
            if p.count > 1, p[1].count > 2 {
                if let a = Float(p[1]), a == 0 { places = 0 }
                else { places = min(p[1].count,7) }
            }
            let period = b.4.components(separatedBy: " ")
            if period.count > 1 { lblTime.text = period[1] }
            lblDate.text  = period[0] //b.4
            lblPair.text  = b.1
            lblPrice.text = "\(price)".toCurrency(places)
            lblQty.text   = b.3
        }
    }
    
    override func layoutViews() {
        super.layoutViews()
        
        lblDate.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        lblPair.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        lblPrice.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        lblQty.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        lblDate.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.24).isActive = true
        lblPair.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.20).isActive = true
        lblPrice.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.28).isActive = true
        lblQty.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.28).isActive = true
        
        lblDate.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.0).isActive = true
        lblPair.leadingAnchor.constraint(equalTo: lblDate.trailingAnchor, constant: 5.0).isActive = true
        
        lblPrice.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10.0).isActive = true
        lblQty.trailingAnchor.constraint(equalTo: lblPrice.leadingAnchor, constant: -5.0).isActive = true
        
        lblTime.leadingAnchor.constraint(equalTo: lblDate.leadingAnchor).isActive = true
        lblTime.bottomAnchor.constraint(equalTo: lblDate.topAnchor).isActive = true
    }
}

