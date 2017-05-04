//
//  Model.swift
//  KyivMetro
//
//  Created by Ali on 4/27/17.
//  Copyright © 2017 Ali. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: App's Localization
public enum Language {
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

// MARK: Station as Vertex in Graph
final public class Station {
    
    public typealias LocalizedString = (UA: String, RU: String, ENG: String)
    
    private let subwayLine: LocalizedString
    private let subwayStation: LocalizedString
    
    public var station : String {
        switch language {
        case .English: return subwayStation.ENG
        case .Ukrainian: return subwayStation.UA
        case .Russian: return subwayStation.RU
        }
    }
    
    public var line : String {
        switch language {
        case .English: return subwayLine.ENG
        case .Ukrainian: return subwayLine.UA
        case .Russian: return subwayLine.RU
        }
    }
    
    var language: Language
    
    public var coords: CLLocation
    
    static func == (lhs: Station, rhs: Station) -> Bool {
        return lhs.subwayStation.ENG == lhs.subwayStation.ENG && lhs.subwayLine.ENG == rhs.subwayLine.ENG
    }
    
    static func == (lhs: Station, rhs: String) -> Bool {
        return rhs == lhs.subwayStation.ENG || rhs == lhs.subwayStation.RU ||  rhs == lhs.subwayStation.UA
    }
    
    static func == (lhs: String, rhs: Station) -> Bool {
        return rhs == lhs
    }
    
    public init(station: LocalizedString, line: LocalizedString, coordinates: CLLocation, language: Language) {
        self.subwayLine = line
        self.coords = coordinates
        self.subwayStation = station
        self.language = language
    }
}

// MARK: Modefied Depth-First-Search
fileprivate class Searcher {
    
    let matrix: [[Double]]
    var paths: [[Int]]
    
    init(matrix: [[Double]]) {
        self.matrix = matrix
        paths = []
    }
    
    func search(start: Int, end: Int) {
        paths = []
        search(start: start, end: end, path: [])
    }
    
    private func search(start: Int, end: Int, path: [Int]) {
        for (index, value) in matrix[start].enumerated() {
            if !path.contains(index) && value != 0 {
                if index != end {
                    search(start: index, end: end, path: path + [start]);
                } else {
                    paths.append(path + [start, index]);
                }
            }
        }
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
    
    func search(from: String, to: String) -> [[Station]] {
    
        let p1 = stations.index(where: { $0 == from })!
        let p2 = stations.index(where: { $0 == to })!
        
        searcher.search(start: p1, end: p2)
        return searcher.paths.map({ $0.map({ stations[$0] })})
    }
    
    func isValidStation(station: String) -> Bool {
        return stations.contains(where: { $0 == station })
    }
    
    func changeLanguage(for language: Language) {
        self.language = language
        for i in 0..<stations.count {
            stations[i].language = language
        }
    }
    
    init(language: Language) {
        
        self.language = language
        
        // Download graph
        let stationsJson = readJSON(name: "Stations") as? [[String : Any]] ?? [[:]]
        let edges = readJSON(name: "Graph") as? [[String : String]] ?? [[:]]
        
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
            
            for value in Array($0) {
                let row = Int(value.key) ?? 0
                let column = Int(value.value) ?? 0
                
                matrix[row][column] = 1
                matrix[column][row] = 1
            }
        })
        
        searcher = Searcher(matrix: matrix)
    }
}
