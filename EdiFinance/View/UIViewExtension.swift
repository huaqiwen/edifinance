//
//  File.swift
//  EdiFinance
//
//  Created by Peter Ke on 2018-05-06.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import UIKit

// allows adding corner radius and border in storyboard
// from http://stackoverflow.com/questions/28854469/change-uibutton-bordercolor-in-storyboard
extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

