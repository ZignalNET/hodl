//
//  ExchangeTableViewCell.swift
//  hodl
//
//  Created by Emmanuel Adigun on 2022/06/24.
//

import UIKit

class ExchangeTableViewCell: GenericTableViewCell {
    private let imgExchange  = UIImageView()
    private let lblExchange     = UILabel( "", .left,  12, .regular, .lightGray)
    
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
        imgExchange.translatesAutoresizingMaskIntoConstraints = false
        roundCorners(5.0, .defaultLineColor, 0.2)
        addSubview(lblExchange)
        addSubview(imgExchange)
    }
    
    override func onConfigureCell(cell: UITableViewCell, model: Any) {
        let b = model as! (String,Int)
        imgExchange.image = nil
        lblExchange.text = b.0.capitalized
        imgExchange.setImage(b.0.lowercased(), 9.0)
        accessoryType = b.1 == 1 ? .checkmark : .none
    }
    
    override func layoutViews() {
        super.layoutViews()
        
        imgExchange.heightAnchor.constraint(equalToConstant: 18).isActive = true
        imgExchange.widthAnchor.constraint(equalToConstant: 18).isActive = true
        
        imgExchange.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.0).isActive = true
        imgExchange.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        lblExchange.leadingAnchor.constraint(equalTo: imgExchange.trailingAnchor, constant: 5.0).isActive = true
        lblExchange.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
}

