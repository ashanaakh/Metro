//
//  Model.swift
//  Metro
//
//  Created by Ali on 4/27/17.
//  Copyright © 2017 Ali. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: App's Localization
public enum Language: Int {
    case Russian
    case Ukrainian
    case English
}

// MARK: JSON reader
fileprivate func readJSON(name: String) -> Any {
    do {
        if let file = Bundle.main.url(forResource: name, withExtension: "json") {
            let data = try Data(contentsOf: file)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            if let object = json as? [String : Any] {
                return object
            } else if let object = json as? [Any] {
                return object
            } else {
                fatalError("JSON is invalid")
            }
        } else {
            fatalError("No file")
        }
    } catch {
        print(error.localizedDescription)
        fatalError()
    }
}

// MARK: Model in Model-View-Controller Pattern
final class Model {

    fileprivate var startStation: Station!
    fileprivate var endStation: Station!

    fileprivate var isStartEnable = false
    fileprivate var isEndEnable = false

    fileprivate var searcher: Searcher!

    var language: Language

    var stations = [Station]()

    func search(from: String, to: String) -> [([Station], String)] {

        let p1 = stations.index(where: { $0 == from })!
        let p2 = stations.index(where: { $0 == to })!

        searcher.search(start: p1, end: p2)

        // Time
        let result = searcher.paths.map { (array) -> ([Station], String) in
            let p = array.map({ stations[$0] })

            var time = 0
            for i in 0..<array.count - 1 {
                time += Int(searcher.matrix[array[i]][array[i + 1]])
            }

            let pathTime = time + (array.count - 1) * 20
            let hours = pathTime / 3600
            let mins = (pathTime - hours * 60) / 60

            if hours > 0 {
                return (p, "\(hours) hours and \(mins) minutes")
            } else {
                return (p, "\(mins) minutes")
            }

        }

        return result
    }

    func isValidStation(station: String) -> Bool {
        return stations.contains(where: { $0 == station })
    }

    func changeLanguage(for language: Language) {
        self.language = language

        let defaults = UserDefaults.standard
        defaults.set(language.rawValue, forKey: "Language")

        for i in 0..<stations.count {
            stations[i].language = language
        }
    }

    init(language: Language) {

        self.language = language

        let stationsFileName = "Stations"
        let routeFileName = "Graph"

        // Download graph
        let stationsJson = readJSON(name: stationsFileName) as? [[String : Any]] ?? [[:]]
        let edges = readJSON(name: routeFileName) as? [[String : Any]] ?? [[:]]

        stations = stationsJson.flatMap { (xxx) -> [Station] in
            var ru = xxx["lineRU"] as! String
            var ua = xxx["lineUA"] as! String
            var eng = xxx["lineENG"] as! String
            let localLine = Station.LocalizedString(UA: ua, RU: ru, ENG: eng)

            let x = (xxx["stations"] as! [[String : Any]]).map({ (value) -> Station in
                ru = value["nameRU"] as! String
                ua = value["nameUA"] as! String
                eng = value["nameENG"] as! String
                let localString = Station.LocalizedString(UA: ua, RU: ru, ENG: eng)

                let a = (value["location"] as! [String : Double])["lng"]!
                let b = (value["location"] as! [String : Double])["lat"]!

                let location = CLLocation(latitude: b, longitude: a)

                return Station(station: localString, line: localLine, coordinates: location, language: language)
            })
            return x
        }
        // Built Sym Matrix

        var matrix = [[Double]](repeating: [Double](repeating: 0, count: stations.count), count: stations.count)

        edges.forEach({
                let row = $0["from"] as! Int
                let column = $0["to"] as! Int
                let time = Double($0["time"] as! String)!

                matrix[row][column] = time
                matrix[column][row] = time
        })

        searcher = Searcher(matrix: matrix)
    }
}
