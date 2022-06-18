//
//  BadgeView.swift
//  Part of my local repo
//
//  Created by Emmanuel Adigun on 2021/05/20.
//  Copyright © 2021 Zignal Systems. All rights reserved.
//
import UIKit

class BadgeView: BaseView {
    private let height:CGFloat = 24.0
    private var width:CGFloat  = 24.0
    private let badgeLabel = UILabel( "", .center, 10, .bold, .black)
    private var pointSize: CGFloat  = 10.0
    var widthConstraint:NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setupView() {
        super.setupView()
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        let labelWidth        = badgeLabel.calculateBoundingRect(fontSize: pointSize).width
        widthConstraint = self.widthAnchor.constraint(equalToConstant: labelWidth+12)
        widthConstraint.isActive = true
        
        backgroundColor = .white
        roundCorners(height/2)
        
        self.addSubview(badgeLabel)
        
        badgeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        badgeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func updateBadgeText(_ newValue: String = "" ) {
        badgeLabel.text = newValue
        var x = badgeLabel.calculateBoundingRect(fontSize: pointSize).width
        var diff: CGFloat = 0
        if x <= self.width {x = self.width}
        else {diff = 12}
        widthConstraint.isActive = false
        widthConstraint = self.widthAnchor.constraint(equalToConstant: x+diff)
        widthConstraint.isActive = true
    }
}

extension BadgeView {
    convenience init(_ badgeText: String = "" ) {
        self.init()
        updateBadgeText(badgeText)
    }
}
