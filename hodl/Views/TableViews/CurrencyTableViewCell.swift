//
//  CurrencyTableViewCell.swift
//  hodl
//
//  Created by Emmanuel Adigun on 2022/06/16.
//

import UIKit

class CurrencyTableViewCell: GenericTableViewCell {
    private let lblAsterisk     = UILabel( "", .left,  12, .bold, .white)
    private let lblCurrency     = UILabel( "",  .left,  12, .regular, .lightGray)
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
        addSubview(lblAsterisk)
        addSubview(lblCurrency)
    }
    
    override func onConfigureCell(cell: UITableViewCell, model: Any) {
        let b = model as! (String,Int)
        lblCurrency.text = b.0
        lblCurrency.textColor = b.1 == 1 ? .white : .lightGray
        lblAsterisk.text = b.1 == 1 ? "*" : ""
        accessoryType = b.1 == 1 ? .checkmark : .none
    }
    
    override func layoutViews() {
        super.layoutViews()
        
        lblCurrency.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.0).isActive = true
        lblCurrency.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        lblAsterisk.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        lblAsterisk.leadingAnchor.constraint(equalTo: lblCurrency.trailingAnchor).isActive = true
    }
}
