import XCTest
import SwiftyJSON
@testable import SwiftyJSearch

@available(macOS 13.0, *)
final class SwiftyJSearchTests: XCTestCase {
    
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
    
    func testSetup() {
        let json = try? JSON(data: self.testData)
        print(json!.description)
        XCTAssertNotNil(json)
    }
    
    func testSingleKeyAll() {
        let json = try? JSON(data: self.testData)
        let results = json?.bfs(for: "brand", returning: .all)
        XCTAssertNotNil(results)
        XCTAssertEqual(results!.count, 5)
        XCTAssertTrue(results!.contains(where: {$0.stringValue == "Chevy"}))
        XCTAssertTrue(results!.contains(where: {$0.stringValue == "Ford"}))
        XCTAssertTrue(results!.contains(where: {$0.stringValue == "Tesla"}))
        XCTAssertTrue(results!.contains(where: {$0.stringValue == "Gibson"}))
        XCTAssertTrue(results!.contains(where: {$0.stringValue == "Fender"}))
    }
    
    func testSingleKeyFirst() {
        let json = try? JSON(data: self.testData)
        var resultArr: [String?] = []
        for i in 0..<20 {
            let results = json?.bfs(for: "brand", returning: .first)
            resultArr.append(results?.first?.stringValue)
            XCTAssertEqual(resultArr[i], "Fender")
        }
        XCTAssertEqual(resultArr.count, 20)
    }
    
    func testSingleKeyLast() {
        let json = try? JSON(data: self.testData)
        var resultArr: [String?] = []
        for i in 0..<20 {
            let results = json?.bfs(for: "brand", returning: .last)
            resultArr.append(results?.first?.stringValue)
            XCTAssertEqual(resultArr[i], "Tesla")
        }
        XCTAssertEqual(resultArr.count, 20)
    }
    
    func testMultiKeyAll() {
        let json = try? JSON(data: self.testData)
        guard let results = json?.bfs(for: ["brand", "gasoline"], returning: .all) else { XCTFail(); return; }
        XCTAssertEqual(results["brand"], [JSON(stringLiteral: "Fender"),JSON(stringLiteral: "Gibson"),JSON(stringLiteral: "Chevy"),JSON(stringLiteral: "Ford"),JSON(stringLiteral: "Tesla")])
        XCTAssertEqual(results["gasoline"], [JSON(booleanLiteral: true),JSON(booleanLiteral: true),JSON(booleanLiteral: false)])
    }
    
    func testMultiKeyFirst() {
        let json = try? JSON(data: self.testData)
        var resultArr: [String?] = []
        for i in 0..<20 {
            let results = json?.bfs(for: ["brand", "gasoline"], returning: .first)
            resultArr.append(results?["brand"]?.first?.stringValue)
            XCTAssertEqual(resultArr[i], "Fender")
        }
        var resultArr2: [Bool?] = []
        for i in 0..<20 {
            let results = json?.bfs(for: ["brand", "gasoline"], returning: .first)
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
            XCTAssertEqual(resultArr[i], "Tesla")
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
        let results = json?.bfs(for: "brand", excluding: ["secondContents"], returning: .all)
        XCTAssertEqual(results?.count, 3)
        XCTAssertEqual(results, [JSON(stringLiteral: "Chevy"), JSON(stringLiteral: "Ford"), JSON(stringLiteral: "Tesla")])
    }
    
    func testSpeed() {
        let json = try? JSON(data: self.testData)
        self.measure {
            let _ = json?.bfs(for: "brand", returning: .all)
        }
    }
}
