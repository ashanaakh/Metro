//
//  Station.swift
//  Metro
//
//  Created by Ali on 5/8/17.
//  Copyright © 2017 Ali. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: Station as Vertex in Graph
final public class Station {
    
    public typealias LocalizedString = (UA: String, RU: String, ENG: String)
    
    let subwayLine: LocalizedString
    let subwayStation: LocalizedString
    
    public var name : String {
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
