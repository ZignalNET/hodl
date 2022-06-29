//
//  UIView.swift
//  Part of my local repo
//
//  Created by Emmanuel Adigun on 2021/05/14.
//  Copyright © 2021. All rights reserved.
//

import UIKit

enum LinePosition: Int {
    case top
    case bottom
}

extension UIView {
    
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
     convenience init(_ ofHeight: CGFloat = 20.0, _ withColor: UIColor = .clear) {
        self.init()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: ofHeight).isActive = true
        self.backgroundColor = withColor
    }
    
    func roundCorners(_ cornerRadius: CGFloat, _ borderColor: UIColor = UIColor.clear, _ lineWidth: CGFloat = 1.0) {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        self.layer.borderWidth = lineWidth
        self.layer.borderColor = borderColor.cgColor
    }
    
    
    public func setBorder(_ borderColor: UIColor = UIColor.clear, _ borderWidth: CGFloat = 1.0) {
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
    }
    
    func setBorderColor(_ borderColor: UIColor = UIColor.clear) {
        self.layer.borderColor = borderColor.cgColor
    }
    
    func addLine(to position: LinePosition = .bottom, _ color: UIColor = UIColor.defaultLineColor, _ height: CGFloat = 0.2) {
        let line = UIView(height)
        addSubview(line)
        line.backgroundColor = color
        line.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        switch( position ) {
            case .top: line.topAnchor.constraint(equalTo: self.topAnchor).isActive = true;break
            case .bottom: line.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true;break
        }
    }

}




extension UIView {

    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }

    //fileprivate typealias Action = (() -> Void)?
    typealias Action = (() -> Void)?


    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }


    public func addTapGestureRecognizer(action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
    }


    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }

    class func createStackView(_ axis: NSLayoutConstraint.Axis = .horizontal) -> UIStackView {
        let view = UIStackView()
        view.axis = axis
        view.spacing = 0 //10
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.distribution = .fillProportionally
        view.alignment = .fill
        return view
    }
    
    func createStackView(_ axis: NSLayoutConstraint.Axis = .horizontal) -> UIStackView {
        return UIView.createStackView()
    }
    
    convenience init(_ caption: Any, _ placeHolder: String, _ textView: UITextField?, _ topView: UIView? = nil ) {
        self.init()
        self.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.backgroundColor = .clear
        var withPadding: Bool = true
        var text: UILabel?
        if caption is String {
            text = UILabel( (caption as? String)!, .left, 12, .medium, .lightGray)
        }
        else if caption is UILabel {
            text = (caption as! UILabel)
            withPadding = false
        }
        else {
            text = UILabel( "", .left, 12, .medium, .lightGray)
        }
        if let textView = textView, let text = text {
            addSubview(text)
            text.leadingAnchor.constraint(equalTo: leadingAnchor, constant: withPadding ? 10 : 0).isActive = true
            text.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            text.widthAnchor.constraint(equalTo:   widthAnchor, multiplier: 0.30).isActive = true
                
            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.placeholder = placeHolder
            textView.attributedPlaceholder = NSAttributedString(string: textView.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightText.withAlphaComponent(0.2)])
            textView.font = UIFont.systemFont(ofSize: 12)
            textView.borderStyle = UITextField.BorderStyle.roundedRect
            textView.autocorrectionType = UITextAutocorrectionType.no
            //textView.keyboardType = UIKeyboardType.default
            textView.returnKeyType = UIReturnKeyType.done
            textView.clearButtonMode = UITextField.ViewMode.whileEditing
            textView.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
            textView.text = textView.text
            textView.textColor = .white
            textView.backgroundColor = .collectionCellColor
            addSubview(textView)
            
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
            textView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            textView.widthAnchor.constraint(equalTo:   widthAnchor, multiplier: 0.7).isActive = true
            textView.heightAnchor.constraint(equalTo:  heightAnchor).isActive = true
        }
        
        if let topView = topView, let textView = textView {
            topView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(topView)
            topView.leadingAnchor.constraint(equalTo: textView.leadingAnchor).isActive = true
            topView.bottomAnchor.constraint(equalTo: textView.topAnchor).isActive = true
        }
    }
    
}

