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
    
    
    func testContains() {
        guard let json = try? JSON(data: self.testData) else { XCTFail(); return; }
        let tree = JSONTree(json: json)
        print(tree.prettyFormat)
        XCTAssertTrue(tree.contains("Camaro"))
        XCTAssertTrue(tree.contains(true))
        XCTAssertTrue(tree.contains(2323.12))
        XCTAssertFalse(tree.contains("Hellcat"))
        XCTAssertFalse(tree.contains(3234.21))
    }
}
