//
//  NearCell.swift
//  KyivMetro
//
//  Created by Ali on 5/3/17.
//  Copyright © 2017 Ali. All rights reserved.
//

import UIKit

class NearCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIView!
    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var distanceInKm: UILabel!
    
    func set(name: String, distance: Double) {
        distanceInKm.text = String(round(distance * 100) / 100) + " km"
        stationName.text = name
        icon.layer.cornerRadius = icon.bounds.size.width / 2 // Circle
        icon.layer.borderWidth = 1;
        icon.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        icon.flash()
    }
}
