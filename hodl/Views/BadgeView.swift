//
//  BadgeView.swift
//  Part of my local repo
//
//  Created by Emmanuel Adigun on 2021/05/20.
//  Copyright © 2021 Zignal Systems. All rights reserved.
//
import UIKit

class BadgeView: BaseView {
    private var height:CGFloat = 28.0
    private var width:CGFloat  = 28.0
    private let badgeLabel = UILabel( "", .center, 12, .bold, .black)
    private var pointSize: CGFloat  = 12.0
    private var badgeColor: UIColor = .black
    private var badgeBackgroundColor: UIColor = .white
    
    var widthConstraint:NSLayoutConstraint!
    var heightConstraint:NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setupView() {
        super.setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    private func layout() {
        var x = badgeLabel.calculateBoundingRect(fontSize: pointSize).width
        var diff: CGFloat = 0
        if x <= self.width {x = self.width}
        else {diff = 12}
        widthConstraint.isActive = false
        widthConstraint = self.widthAnchor.constraint(equalToConstant: x+diff)
        widthConstraint.isActive = true
    }
    
    private func roundedLine() {
        let center = self.center
        let lineLayer = CAShapeLayer()
        lineLayer.strokeColor = UIColor.defaultLineColor.cgColor;
        lineLayer.fillColor = UIColor.clear.cgColor;
        lineLayer.path = UIBezierPath(ovalIn: CGRect(x: center.x, y: center.y, width: width, height: height)).cgPath
        self.layer.addSublayer(lineLayer)
    }
    
    func updateBadgeText(_ newValue: String = "" ) {
        badgeLabel.text = newValue
        badgeLabel.textColor = badgeColor
        layout()
    }
}

extension BadgeView {
    convenience init(_ badgeText: String = "", _ textColor: UIColor, _ backColor: UIColor, _ width: CGFloat = 28.0, _ height: CGFloat = 28 , _ lineColor: UIColor = UIColor.clear, _ pointSize: CGFloat = 12.0) {
        self.init()
        self.width = width
        self.height = height
        self.badgeColor = textColor
        self.pointSize  = pointSize
        self.backgroundColor = backColor
        self.addSubview(badgeLabel)
        badgeLabel.font = UIFont.systemFont(ofSize: pointSize, weight: .bold)
        roundCorners(height/2, lineColor, 0.25)
        
        heightConstraint = self.heightAnchor.constraint(equalToConstant: height)
        widthConstraint  = self.widthAnchor.constraint(equalToConstant: width)
        widthConstraint.isActive = true
        heightConstraint.isActive = true
        
        badgeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        badgeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        updateBadgeText(badgeText)
    }
}
