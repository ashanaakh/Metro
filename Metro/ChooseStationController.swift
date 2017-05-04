//
//  ChooseStationController.swift
//  KyivMetro
//
//  Created by Ali on 4/28/17.
//  Copyright © 2017 Ali. All rights reserved.
//

import UIKit
import CoreLocation

protocol ChooseStationControllerDelegate {
    func set(station: Station)
    var stations: [Station] { get }
    var language: Language { get }
}

class ChooseStationController: UITableViewController{
    
    // Uses for detecting user's location
    var locationManager = CLLocationManager()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // Previous Controller as ChooseStationControllerDelegate
    var delegate: ChooseStationControllerDelegate!
    
    // Random Colors for tableView (= to numberOfSections - 1)
    var colors = [UIColor]()
    
    // Created for SearchController
    var filteredArray = [(line: String, stations: [String])]()
    
    // Line and stations on it
    var array = [(line: String, stations: [String])]()
    
    // Nearest stations
    var nearStations = [(station: String, distance: Double)]()
    
    var showNear: Bool {
        let notEmpty = !searchController.searchBar.text!.isEmpty
        let activeSearch = searchController.isActive
        return !activeSearch && !notEmpty && !nearStations.isEmpty
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeSearchController()
        
        // Sort Subway Lines
        let lines = Set(delegate.stations.flatMap({ $0.line })).sorted()
        
        array = lines.map({ (line) -> (line: String, stations: [String]) in
            let s = delegate.stations.filter({ $0.line == line }).flatMap({ $0.station })
            return (line, stations: s)
        })
        filteredArray = array
        
        // Color random
        lines.forEach({ _ in colors.append(randomColor())})
        
        // User's Current Location (CoreLocation)
        locationManager.requestWhenInUseAuthorization()
        
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation() // Start
    }
    
    func randomColor() -> UIColor {
        let b = CGFloat(arc4random_uniform(255)) / 255
        let g = CGFloat(arc4random_uniform(255)) / 255
        let a = CGFloat(arc4random_uniform(100) + 100) / 255
    
        return UIColor(red: 0, green: g, blue: b, alpha: a)
    }
    
    // MARK: TableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return showNear ? array.count + 1 : filteredArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard showNear else {
            return filteredArray[section].stations.count
        }
        
        switch section {
        case 0:  return nearStations.count
        default: return array[section - 1].stations.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard showNear else {
            return filteredArray[section].line
        }
        
        // Language
        switch section {
        case 0 where delegate.language == .English: return "Nearest"
        case 0 where delegate.language == .Russian: return "Ближайшие"
        case 0 where delegate.language == .Ukrainian: return "Найближчі"
        default: return array[section - 1].line
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            return cellFor(indexPath: indexPath)
    }
    
    func cellFor(indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let section = showNear ? indexPath.section - 1 : indexPath.section
        
        switch indexPath.section {
        case 0 where showNear:
            let nearCell = tableView.dequeueReusableCell(withIdentifier: "NCell", for: indexPath) as! NearCell
            nearCell.set(name: nearStations[indexPath.row].station , distance: nearStations[indexPath.row].distance / 1000)
            nearCell.backgroundColor = #colorLiteral(red: 0.9685354829, green: 0.968693912, blue: 0.9685017467, alpha: 1)
            cell = nearCell
        default:
            let stationCell = tableView.dequeueReusableCell(withIdentifier: "SCell", for: indexPath) as! StationCell
            let line = (showNear ? filteredArray : array)[section]
            stationCell.set(lineIcon: line.line, stationName: line.stations[indexPath.row])
            stationCell.backgroundColor = colors[section]
            cell = stationCell
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stationName: String
        if showNear {
            stationName = (indexPath.section == 0 ?
                nearStations[indexPath.row].station :
                array[indexPath.section - 1].stations[indexPath.row])
        } else {
            let arrayInSection = filteredArray[indexPath.section]
            stationName = arrayInSection.stations[indexPath.row]
        }
        let station = delegate.stations.first(where: { stationName == $0.station })!
        delegate.set(station: station)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: UISearchController
extension ChooseStationController : UISearchResultsUpdating {
    func filterContent(for searchText: String) {
        filteredArray = array
        
        filteredArray.enumerated().forEach { (x) in
            filteredArray[x.offset].stations = x.element.stations.filter({
                $0.lowercased().contains(searchText.lowercased())
            })
        }
        // Remove line if it is empty
        filteredArray = filteredArray.filter({ !$0.stations.isEmpty })
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            filterContent(for: text)
        }
        tableView.reloadData()
    }
    
    func makeSearchController() {
        // SearchController
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        // Language
        let placeholder: String
        switch delegate.language {
        case .English: placeholder = "Station"
        case .Ukrainian: placeholder = "Станція"
        case .Russian: placeholder = "Станция"
        }
        searchController.searchBar.placeholder = placeholder
        
        searchController.searchBar.barTintColor = #colorLiteral(red: 0.405847405, green: 0.852046767, blue: 1, alpha: 1)
        searchController.searchBar.tintColor = .white
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
}

// MARK: CLLocationManagerDelegate
extension ChooseStationController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let dist = { (x: CLLocation) -> Double in
            return locations[0].distance(from: x)
        }
        
        let near = delegate.stations.map{
            ($0.station, dist($0.coords))
            }.sorted(by: { $0.0.1 < $0.1.1 })
        nearStations = Array(near.map{($0.0, $0.1)}[0...2])
        tableView.reloadData()
    }
}
