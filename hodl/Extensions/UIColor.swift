//
//  UIColor+Extensions.swift
//  Part of my local repo
//
//  Created by Emmanuel Adigun on 2020/03/31.
//  Copyright © 2020. All rights reserved.
//


import UIKit

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int, alpha: Float) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha))
    }
    
    convenience init(rgb: Int, alpha: Float) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            alpha: alpha
        )
    }
    
    convenience init(rgbHexValue: UInt32){  // e.g UIColor(0x034517)
        self.init(
            red: CGFloat((rgbHexValue & 0xFF0000) >> 16)/256.0,
            green: CGFloat((rgbHexValue & 0xFF00) >> 8)/256.0,
            blue: CGFloat(rgbHexValue & 0xFF)/256.0,
            alpha: 1.0
        )
    }
    
    static func RGBA( _ red: Int, _ green: Int, _ blue: Int, _ alpha: Float = 1.0 ) -> UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    //Create image from color. :) funky!!
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    class func colorForNavBar(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        //    Or if you need a thinner border :
        //    let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 0.5)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        context!.setFillColor(color.cgColor)
        context!.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }
    
    
    
    static let defaultAppStrongColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
    
    static let defaultCircleFillColor = UIColor(rgb: 0x004080, alpha: 1.0)
    static let defaultCircleTextColor = UIColor(rgb: 0xFFFFFF, alpha: 1.0)
    
    static let defaultSwitchOnFillColor = UIColor(rgb: 0x004080, alpha: 1.0)
    static let defaultSwitchOffFillColor = UIColor(rgb: 0x004080, alpha: 0.5)
    
    static let defaultBorderColor = UIColor(rgb: 0x280e45, alpha: 0.1)
    
    static let defaultBackgroundColor: UIColor = .white
    static let defaultBackgroundColor1: UIColor = RGBA(19,26,35)
    static let defaultBackgroundColor2: UIColor = .darkText
    
    static let defaultHeaderDetailsBackgroundColor: [UIColor] = [RGBA(20,35,77),RGBA(14, 64, 199)]
    
    static let mediumSeaGreenColor: UIColor = RGBA(33, 186, 109)
    static let shadowColor: UIColor = RGBA(20,35,77)
    static let collectionCellColor: UIColor = RGBA(98, 110, 126,0.1)
    static let defaultLineColor: UIColor = RGBA(98, 110, 126,0.6)
    static let tableCellColor: UIColor = collectionCellColor
    
    static let defaultGraphStrokeColor: UIColor = RGBA(98, 110, 126,0.4)
    static let barChartGreenColor: UIColor = mediumSeaGreenColor
    static let barChartRedColor: UIColor = UIColor(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
    
    static let chartLengendTextColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3318812193)
    static let tabBarColor: UIColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
    static let navigationBarTitleTextColor: UIColor = mediumSeaGreenColor
    
    static let switchOnColor = navigationBarTitleTextColor
    static let defaultAppTitleColor = UIColor.navigationBarTitleTextColor.withAlphaComponent(0.5)
    
    static let statGreenColor   = mediumSeaGreenColor
    static let statRedColor     = defaultAppStrongColor
    
    static let appBorderColor: UIColor = RGBA(98, 110, 126,0.4)
    
    static let headerViewTextColor = UIColor.white
    static let headerViewSubTextColor = statGreenColor
}

