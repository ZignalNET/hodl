//
//  GenericTableViewCell.swift
//  Part of my local repo
//
//  Created by Emmanuel Adigun on 2021/05/17.
//  Copyright © 2021 Zignal Systems. All rights reserved.
//

import UIKit

class GenericTableViewCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func commonInit() {
        backgroundColor = .collectionCellColor
        roundCorners(5.0, .collectionCellColor)
    }
   
    func layoutViews() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
    }

}


