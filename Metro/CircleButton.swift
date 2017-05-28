//
//  CircleButton.swift
//  Metro
//
//  Created by Ali on 5/28/17.
//  Copyright © 2017 Ali. All rights reserved.
//

import UIKit

@IBDesignable class CircleButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
}
