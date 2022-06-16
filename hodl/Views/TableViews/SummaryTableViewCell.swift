//
//  SummaryTableViewCell.swift
//  hodl
//
//  Created by Emmanuel Adigun on 2022/06/09.
//

import UIKit

class SummaryTableViewCell: GenericTableViewCell {
    private let imgExchange  = UIImageView()
    private let lblExchange  = UILabel( "", .left,  14, .regular, .lightGray)
    private let lblTotal     = UILabel( "", .right, 14, .regular, .mediumSeaGreenColor)
    
    override func onConfigureCell(cell: UITableViewCell, model: Any) {
        let b = model as! (String,(Float,AssetsBalances?,Exchanges?))
        imgExchange.image = nil
        if b.0 == "" {
            lblExchange.text = "Loading ..."
        }
        else {
            lblExchange.text         = b.0.capitalized
            lblTotal.text            = "\(b.1.0)".toCurrency
            if let img = lblExchange.text {
                imgExchange.setImage(img.lowercased(), 9.0)
            }
        }
    }
    
    override func onSelectedCell(index: Int, cell: UITableViewCell, model: Any) {
        
    }
    
    override func commonInit() {
        super.commonInit()
        
        imgExchange.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imgExchange)
        addSubview(lblExchange)
        addSubview(lblTotal)
        
        backgroundColor = .clear
    
    }
    
    override func layoutViews() {
        super.layoutViews()
        
        imgExchange.heightAnchor.constraint(equalToConstant: 18).isActive = true
        imgExchange.widthAnchor.constraint(equalToConstant: 18).isActive = true
        
        imgExchange.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.0).isActive = true
        imgExchange.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        lblExchange.leadingAnchor.constraint(equalTo: imgExchange.trailingAnchor, constant: 5.0).isActive = true
        lblExchange.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        lblTotal.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10.0).isActive = true
        lblTotal.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    

}
