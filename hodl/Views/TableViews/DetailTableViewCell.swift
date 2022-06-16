//
//  DetailTableViewCell.swift
//  hodl
//
//  Created by Emmanuel Adigun on 2022/06/10.
//

import UIKit

class DetailTableViewCell: GenericTableViewCell {
    private let imgAsset     = UIImageView("")
    private let lblAsset     = UILabel( "", .left,  12, .regular, .lightGray)
    private let lblTotal     = UILabel( "", .right, 12, .medium, .white)
    private let lblValue     = UILabel( "", .right, 12, .medium, .mediumSeaGreenColor)
    
    override func onConfigureCell(cell: UITableViewCell, model: Any) {
        let b = model as! (String,String,String)
        lblAsset.text = b.0
        lblTotal.text = b.1
        lblValue.text = b.2
        imgAsset.image = nil
        imgAsset.setImage(b.0.lowercased(), 10.0)
    }
    
    override func onSelectedCell(index: Int, cell: UITableViewCell, model: Any) {
        
    }
    
    override func commonInit() {
        super.commonInit()
        
        addSubview(imgAsset)
        addSubview(lblAsset)
        addSubview(lblTotal)
        addSubview(lblValue)

        backgroundColor = .clear
    
    }
    
    override func layoutViews() {
        super.layoutViews()
        
        imgAsset.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.0).isActive = true
        imgAsset.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        lblAsset.leadingAnchor.constraint(equalTo: imgAsset.trailingAnchor, constant: 5.0).isActive = true
        lblAsset.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        lblValue.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10.0).isActive = true
        lblValue.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        lblTotal.trailingAnchor.constraint(equalTo: lblValue.leadingAnchor, constant: -5.0).isActive = true
        lblTotal.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        lblValue.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3).isActive = true
        
        imgAsset.heightAnchor.constraint(equalToConstant: 20).isActive = true
        imgAsset.widthAnchor.constraint(equalToConstant: 20).isActive = true
    }
    

    func rePaintHeader() {
        self.roundCorners(0, .clear, 0.0)  //header
        lblAsset.textColor = .white
        lblTotal.textColor = .white
        lblValue.textColor = .white
    }

}
