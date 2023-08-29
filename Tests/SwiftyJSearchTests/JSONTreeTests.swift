//
//  TreeFormattedTests.swift
//  
//
//  Created by Sean Erickson on 8/28/23.
//

import XCTest
import SwiftyJSON
@testable import SwiftyJSearch
final class JSONTreeTests: XCTestCase {
    
    var testData: Data!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let packageURL = URL(fileURLWithPath: #file).deletingLastPathComponent()
        let fileURL = packageURL.appendingPathComponent("JSON/Test1")
        guard let data = try? Data(contentsOf: fileURL) else {
            XCTFail()
            return
        }
        self.testData = data
    }
    
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        guard let json = try? JSON(data: self.testData) else { XCTFail(); return; }
        let tree = JSONTree(json: json)
        print(tree.prettyFormat)
    }
}
