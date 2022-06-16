//
//  UILabel.swift
//  Part of my local repo
//
//  Created by Emmanuel Adigun on 2021/05/19.
//  Copyright © 2021. All rights reserved.
//

import UIKit

extension UILabel {
    
    convenience init(_ text: String, _ textAlignment: NSTextAlignment = .center, _ size: Int = 20, _ weight: UIFont.Weight = .medium, _ textColor: UIColor = .white) {
        self.init()
        
        self.isUserInteractionEnabled = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.text = text
        self.textAlignment = textAlignment
        self.font = UIFont.systemFont(ofSize: CGFloat(size), weight: weight)
        self.textColor = textColor
    }
    
    func calculateBoundingRect(_ fontName: String = "HelveticaNeue", fontSize: CGFloat = 17) -> CGRect {
        if let messageText = self.text {
        let size = CGSize.init(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimateFrame = NSString(string: messageText).boundingRect(with:  size, options: options, attributes: [NSAttributedString.Key.font: UIFont(name: fontName, size: fontSize)!], context: nil)
            return estimateFrame
        }
        else
        {
            return CGRect.zero
        }
    }
    
}

