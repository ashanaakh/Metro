//
//  StationCell.swift
//  Metro
//
//  Created by Ali on 4/28/17.
//  Copyright © 2017 Ali. All rights reserved.
//

import UIKit

class StationCell: UITableViewCell {

    @IBOutlet weak var lineIcon: UIImageView!
    @IBOutlet weak var stationName: UILabel!

    func set(lineIcon: String, stationName: String) {
        self.lineIcon.image = UIImage(named: String(lineIcon.characters.first!))
        self.stationName.text = stationName
    }
}



