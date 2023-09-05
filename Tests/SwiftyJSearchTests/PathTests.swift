//
//  PathTests.swift
//  
//
//  Created by Sean Erickson on 9/5/23.
//

import XCTest
@testable import SwiftyJSearch
final class PathTests: XCTestCase {

    var testData: Data!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let packageURL = URL(fileURLWithPath: #file).deletingLastPathComponent()
        let fileURL = packageURL.appendingPathComponent("JSON/Test1.json")
        guard let data = try? Data(contentsOf: fileURL) else {
            XCTFail()
            return
        }
        self.testData = data
    }
    
    func testSetup() {
        let json = try? JSON(data: self.testData)
        XCTAssertNotNil(json)
    }
    
    func testPathToKey() {
        let json = try! JSON(data: self.testData)
        let path1 = json.path(to: "guitars")
        let path2 = json.path(to: "cars")
        let path3 = json.path(to: "testTypes")
        let path4 = json.path(to: "key not in json")
        
        XCTAssertEqual(path1, "[...] -> secondContents : [...] -> guitars")
        XCTAssertEqual(path2, "[...] -> firstContents : testTypes : cars")
        XCTAssertEqual(path3, "[...] -> firstContents : testTypes")
        XCTAssertNil(path4)
    }
    
    func testPathToValue() {
        let json = try! JSON(data: self.testData)
        let path1 = json.path(to: "Fender")
        let path2 = json.path(to: 2323.12)
        let path3 = json.path(to: false)
        let path4 = json.pathToNull()
        let path5 = json.path(to: 2323)

        XCTAssertEqual(path1, "[...] -> secondContents : [...] -> guitars : [...] -> brand : Fender")
        XCTAssertEqual(path2, "[...] -> secondContents : [...] -> other things : [...] -> number : 2323.12")
        XCTAssertEqual(path3, "[...] -> firstContents : testTypes : cars : [...] -> car types : [...] -> gasoline : false")
        XCTAssertEqual(path4, "[...] -> secondContents : [...] -> other things : [...] -> null value : null")
        XCTAssertNil(path5)
    }

}
