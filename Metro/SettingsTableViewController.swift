//
//  SettingsTableViewController.swift
//  KyivMetro
//
//  Created by Ali on 5/1/17.
//  Copyright © 2017 Ali. All rights reserved.
//

import UIKit

protocol SettingDelegate {
    func set(language: Language)
    var language: Language { get }
}

class SettingsTableViewController: UITableViewController {
    
    var delegate: SettingDelegate!
    var rowWithCheckmark = 0
    
    override func viewDidLoad() {
        switch delegate.language {
        case .Russian: rowWithCheckmark = 0
        case .English: rowWithCheckmark = 1
        case .Ukrainian: rowWithCheckmark = 2
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        
        for row in 0..<numberOfRows {
            let iPath = IndexPath(row: row, section: indexPath.section)
            
            if let cell = tableView.cellForRow(at: iPath) {
                cell.accessoryType = row == indexPath.row ? .checkmark : .none
            }
        }
        
        // Language
        switch indexPath.row {
        case 0: delegate.set(language: .Russian)
        case 1: delegate.set(language: .English)
        case 2: delegate.set(language: .Ukrainian)
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let res = super.tableView(tableView, cellForRowAt: indexPath)
        if rowWithCheckmark == indexPath.row {
            res.accessoryType = .checkmark
        }
        return res
    }
}
