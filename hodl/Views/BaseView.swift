//
//  BaseView.swift
//  Part of my local repo
//
//  Created by Emmanuel Adigun on 2021/05/13.
//  Copyright © 2021 Zignal Systems. All rights reserved.
//

import UIKit

class BaseView: UIView {
    var viewLayer: CAShapeLayer?
    var fillColor: UIColor?
    
    var viewController: UIViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    convenience init(_ fillColor: UIColor = .collectionCellColor ) {
        self.init()
        self.fillColor = fillColor
    }
    
    func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
    }
    
    func getViewHeight() -> CGFloat {
        return 0.0
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    

}
