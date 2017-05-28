//
//  StationControl.swift
//  Metro
//
//  Created by Ali on 5/27/17.
//  Copyright © 2017 Ali. All rights reserved.
//

import UIKit

extension UIColor {
    static var placeholder : UIColor {
        return .lightGray
    }
}

@IBDesignable class StationView: UIStackView {
    
    private var field = (button: UIButton(), fieldIsEmpty: true)
    private var imageView = UIImageView()
    private var fieldTextColor = UIColor.black
    
    var onTap: (() -> Void)!
    
    @IBInspectable var placeholder: String = "" {
        didSet {
            if field.fieldIsEmpty {
                field.button.setTitle(placeholder, for: .normal)
                field.button.setTitleColor(.placeholder, for: .normal)
            }
        }
    }
    
    @IBInspectable var icon: UIImage = UIImage() {
        didSet {
            imageView.image = icon
        }
    }
    
    @IBInspectable override var spacing: CGFloat {
        didSet {
            super.spacing = spacing
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            field.button.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var fieldColor: UIColor = .clear {
        didSet {
             field.button.backgroundColor = fieldColor
        }
    }
    
    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            field.button.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            field.button.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var textColor: UIColor {
        set {
            fieldTextColor = newValue
            if field.fieldIsEmpty {
                field.button.setTitleColor(fieldTextColor, for: .normal)
            }
        }
        get {
            return fieldTextColor
        }
    }
    
    @IBInspectable var fontSize: CGFloat {
        set {
            field.button.titleLabel!.font =
            field.button.titleLabel!.font.withSize(newValue)
        }
        get {
            return field.button.titleLabel!.font.pointSize
        }
    }
    
    @IBInspectable var text: String {
        set {
            if newValue == "" {
                field.button.setTitle(placeholder, for: .normal)
                field.button.setTitleColor(.placeholder, for: .normal)
                field.fieldIsEmpty = true
            } else {
                field.button.setTitle(newValue, for: .normal)
                field.button.setTitleColor(fieldTextColor, for: .normal)
                field.fieldIsEmpty = false
            }
        }
        get {
            return field.button.currentTitle!
        }
    }

    //MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    //MARK: Private Methods
    
    private func setup() {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.heightAnchor.constraint(equalToConstant: 40).isActive = true
        img.widthAnchor.constraint(equalToConstant: 40).isActive = true
        imageView = img;
        addArrangedSubview(img)
        
        let button = UIButton()
        button.backgroundColor = .lightGray
        button.addTarget(self, action: #selector(fieldTapped), for: .touchUpInside)
        button.setTitle(placeholder, for: .normal)
        field.button = button
        addArrangedSubview(button)
    }
    
    // MARK: Actions
    
    func fieldTapped() {
        onTap()
    }
    
    func hideIcon() {
        imageView.isHidden = true
    }
    
    func showIcon() {
        imageView.isHidden = false
    }
    
    func clear() {
        text = ""
        borderWidth = 0
        hideIcon()
    }
    
    func set(text: String) {
        self.text = text;
        borderWidth = 3
    }
}

