//
//  UIImageView.swift
//  hodl
//
//  Created by Emmanuel Adigun on 2022/06/09.
//

import UIKit

extension UIImageView {
    
    convenience init(_ named: String, _ withRadius: CGFloat = 16.0, _ borderWidth: CGFloat = 0.0, _ borderColor: UIColor = .clear) {
        self.init()
        
        if named.count > 0, let img = UIImage(named: named.lowercased()) {
            image = img
        }
        
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = withRadius
        clipsToBounds = true
    }
    
    convenience init(_ named: String ) {
        self.init()
        if named.count > 0, let img = UIImage(named: named.lowercased()) {
            image = img
        }
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setImage (_ named: String, _ withRadius: CGFloat = 16.0 ) {
        if named.count > 0, let img = UIImage(named: named.lowercased()) {
            image = img
        }
        layer.cornerRadius = withRadius
        clipsToBounds = true
    }
    
    
}


extension UIImage {
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
    
    func resize(_ width: CGFloat, _ height:CGFloat) -> UIImage? {
        let widthRatio  = width / size.width
        let heightRatio = height / size.height
        let ratio = widthRatio > heightRatio ? heightRatio : widthRatio
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func tinted(with color: UIColor, isOpaque: Bool = false) -> UIImage? {
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            color.set()
            withRenderingMode(.alwaysTemplate).draw(at: .zero)
        }
    }
}
