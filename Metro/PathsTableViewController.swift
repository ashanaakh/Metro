//
//  PathsTableViewController.swift
//  KyivMetro
//
//  Created by Ali on 4/28/17.
//  Copyright © 2017 Ali. All rights reserved.
//

import UIKit

class PathsTableViewController: UITableViewController {
    
    var paths: [[Station]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paths.sort(by: { $0.0.count < $0.1.count })
        paths.sort(by: { Set($0.0.map({ $0.line })).count < Set($0.1.map({ $0.line })).count })
    }

    // MARK: TableView

    override func numberOfSections(in tableView: UITableView) -> Int {
        return paths.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "Best \(paths[section].count) stations" }
        
        let x = Set(paths[section].map({ $0.line })).count
        return "\(paths[section].count) stations in \(x) lines"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paths[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SCell", for: indexPath) as! StationCell
        let st = paths[indexPath.section][indexPath.row]
        
        cell.set(lineIcon: st.line, stationName: st.station)
        return cell
    }
}
