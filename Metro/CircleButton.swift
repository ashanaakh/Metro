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

    func update(x: Bool) {
        guard x else {
            backgroundColor = UIColor.Button.disable
            shake()
            return
        }
        change(color: UIColor.Button.enable)
    }

    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "position.x")
        animation.isAdditive = true
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.5
        animation.values = [-15.0, 15.0, -13.0, 13.0, -8.0, 8.0, 0.0]
        layer.add(animation, forKey: "shake")
    }

    func change(color: UIColor, delay: Double = 0.2){
        UIView.animate(withDuration: 0.75, delay: delay, animations: {
            self.backgroundColor = color
        }, completion:nil)
    }

}
