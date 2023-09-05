//
//  DFSTests.swift
//  
//
//  Created by Sean Erickson on 9/1/23.
//

import XCTest
@testable import SwiftyJSearch
final class DFSTests: XCTestCase {

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

    func testSingleKeyAll() {
        let json = try? JSON(data: self.testData)
        let results = json?.dfs(for: "brand", returning: .all)
        XCTAssertNotNil(results)
        XCTAssertEqual(results!.count, 5)
        XCTAssertTrue(results!.contains(where: {$0.stringValue == "Chevy"}))
        XCTAssertTrue(results!.contains(where: {$0.stringValue == "Ford"}))
        XCTAssertTrue(results!.contains(where: {$0.stringValue == "Tesla"}))
        XCTAssertTrue(results!.contains(where: {$0.stringValue == "Gibson"}))
        XCTAssertTrue(results!.contains(where: {$0.stringValue == "Fender"}))
    }
    
    // TODO: - Check Which vals are getting returned first
    func testSingleKeyFirst() {
        let json = try? JSON(data: self.testData)
        var resultArr: [String?] = []
        for i in 0..<20 {
            let results = json?.dfs(for: "brand", returning: .first)
            resultArr.append(results?.first?.stringValue)
            XCTAssertTrue(resultArr[i] == "Fender" || resultArr[i] == "Chevy")
        }
        XCTAssertEqual(resultArr.count, 20)
    }
    
    // TODO: - Check Which vals are getting returned first
    func testSingleKeyLast() {
        let json = try? JSON(data: self.testData)
        var resultArr: [String?] = []
        for i in 0..<20 {
            let results = json?.dfs(for: "brand", returning: .last)
            resultArr.append(results?.first?.stringValue)
            XCTAssertTrue(resultArr[i] == "Tesla" || resultArr[i] == "Gibson")
        }
        XCTAssertEqual(resultArr.count, 20)
    }
    
    func testMultiKeyAll() {
        let json = try? JSON(data: self.testData)
        guard let results = json?.dfs(for: ["brand", "gasoline"], returning: .all) else { XCTFail(); return; }
        XCTAssertTrue(results["brand"]!.contains("Chevy"))
        XCTAssertTrue(results["brand"]!.contains("Ford"))
        XCTAssertTrue(results["brand"]!.contains("Tesla"))
        XCTAssertTrue(results["brand"]!.contains("Gibson"))
        XCTAssertTrue(results["brand"]!.contains("Fender"))
        XCTAssertEqual(results["gasoline"], [JSON(booleanLiteral: true),JSON(booleanLiteral: true),JSON(booleanLiteral: false)])
    }

    func testMultiKeyFirst() {
        let json = try? JSON(data: self.testData)
        var resultArr: [String?] = []
        for i in 0..<20 {
            let results = json?.dfs(for: ["brand", "gasoline"], returning: .first)
            resultArr.append(results?["brand"]?.first?.stringValue)
            XCTAssertTrue(resultArr[i] == "Chevy" || resultArr[i] == "Fender")
        }
        var resultArr2: [Bool?] = []
        for i in 0..<20 {
            let results = json?.dfs(for: ["brand", "gasoline"], returning: .first)
            resultArr2.append(results?["gasoline"]?.first?.boolValue)
            XCTAssertEqual(resultArr2[i], true)
        }
        XCTAssertEqual(resultArr.count, 20)
        XCTAssertEqual(resultArr2.count, 20)
    }
    
    func testMultiKeyLast() {
        let json = try? JSON(data: self.testData)
        var resultArr: [String?] = []
        for i in 0..<20 {
            let results = json?.bfs(for: ["brand", "gasoline"], returning: .last)
            resultArr.append(results?["brand"]?.first?.stringValue)
            XCTAssertTrue(resultArr[i] == "Tesla" || resultArr[i] == "Gibson")
        }
        var resultArr2: [Bool?] = []
        for i in 0..<20 {
            let results = json?.bfs(for: ["brand", "gasoline"], returning: .last)
            resultArr2.append(results?["gasoline"]?.first?.boolValue)
            XCTAssertEqual(resultArr2[i], false)
        }
        XCTAssertEqual(resultArr.count, 20)
        XCTAssertEqual(resultArr2.count, 20)
    }
    
    func testExcluding() {
        let json = try? JSON(data: self.testData)
        let results = json?.dfs(for: "brand", excluding: ["secondContents"], returning: .all)
        XCTAssertEqual(results?.count, 3)
        XCTAssertEqual(results, [JSON(stringLiteral: "Chevy"), JSON(stringLiteral: "Ford"), JSON(stringLiteral: "Tesla")])
    }
    
    func testSpeed() {
        let json = try? JSON(data: self.testData)
        self.measure {
            let _ = json?.dfs(for: "brand", returning: .all)
        }
    }
}
