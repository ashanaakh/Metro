//
//  MetroTest.swift
//  MetroTest
//
//  Created by Ali on 4/27/17.
//  Copyright © 2017 Ali. All rights reserved.
//

import XCTest
import CoreLocation

@testable import Metro

class StationTest: XCTestCase {
    
    func testStation() {
        
        let stationName = Station.LocalizedString(UA: "Академмістечко", RU: "Академгородок", ENG: "Akademmistechko")
        
        let lineName = ("Святошинсько-Броварська","Святошинско-Броварская",
                        "Sviatoshynsko-Brovarska")
        
        let loc = CLLocation(latitude: 50.464784, longitude: 30.355511)
        
        let station = Station(station: stationName, line: lineName, coordinates: loc, language: .English)
        
        XCTAssertEqual(station.coords, loc)
        XCTAssertEqual(station.language, .English)
        XCTAssertEqual(station.line, "Sviatoshynsko-Brovarska")
        XCTAssertEqual(station.name, "Akademmistechko")
        
        XCTAssertTrue(station == "Akademmistechko")
        XCTAssertTrue("Академгородок" == station)
        XCTAssertTrue("Академмістечко" == station)
        
        station.language = .Russian
        XCTAssertEqual(station.line, "Святошинско-Броварская")
        
    }
}

class ModelTest: XCTestCase {
    func testSearch() {
        let model = Model(language: .English)
        
        XCTAssertTrue(model.isValidStation(station: "Akademmistechko"))
        XCTAssertFalse(model.isValidStation(station: "INVALID_STATION"))
        
        model.language = .Russian
        
        XCTAssertTrue(model.isValidStation(station: "Левобережная"))
        XCTAssertTrue(model.isValidStation(station: "Крещатик"))
        XCTAssertFalse(model.isValidStation(station: "INVALID_STATION"))
        
        let result = model.search(from: "Левобережная", to: "Крещатик")
        
        XCTAssertTrue(!result.isEmpty)
        
        model.changeLanguage(for: .English)
        
        XCTAssertTrue(model.language == .English)
        XCTAssertTrue(model.stations[0].language  == .English)
        XCTAssertTrue(model.stations[0].line == "1. Sviatoshynsko-Brovarska")
        XCTAssertTrue(model.stations[0].name == "Akademmistechko")
        
    }
}
