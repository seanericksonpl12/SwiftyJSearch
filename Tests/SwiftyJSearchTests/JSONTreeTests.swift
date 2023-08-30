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
    
    func testEmptyInit() {
        let tree = JSONTree()
        XCTAssertTrue(tree.root.children.isEmpty)
    }
    
    func testRootInit() {
        let root = JSONTree.Node(children: [], content: .string("root"))
        let tree = JSONTree(root: root)
        XCTAssertEqual(tree.root, root)
    }
    
    func testJSONInit() {
        guard let json = try? JSON(data: self.testData) else { XCTFail(); return; }
        let tree = JSONTree(json: json)
        XCTAssertNotNil(tree)
    }
    
    func testContains() {
        guard let json = try? JSON(data: self.testData) else { XCTFail(); return; }
        let tree = JSONTree(json: json)
        XCTAssertTrue(tree.contains("Camaro"))
        XCTAssertTrue(tree.contains(true))
        XCTAssertTrue(tree.contains(2323.12))
        XCTAssertFalse(tree.contains("Hellcat"))
        XCTAssertFalse(tree.contains(3234.21))
    }
    
    func testSearch() {
        let root = JSONTree.Node(children: [], content: .string("root"))
        let tree = JSONTree(root: root)
        let node1 = JSONTree.Node(children: [], content: .bool(true))
        let node2 = JSONTree.Node(children: [], content: .string("test"))
        let node3 = JSONTree.Node(children: [], content: .number(25))
        let node4 = JSONTree.Node(children: [], content: .null(NSNull()))
        let node5 = JSONTree.Node(children: [], content: .string("test child"))
        
        root.children.append(node1)
        root.children.append(node2)
        node1.children.append(node3)
        node1.children.append(node4)
        node2.children.append(node5)
        
        XCTAssertEqual(tree.search(for: "test")?.children, [node5])
        XCTAssertEqual(tree.search(for: 25), node3)
    }
    
    func testCount() {
        guard let json = try? JSON(data: self.testData) else { XCTFail(); return; }
        let tree = JSONTree(json: json)
        print(tree.count)
        print(tree.contentNodeCount)
        print(tree.prettyFormat)
    }
    
    func testRemoveAllEndNode() {
        let root = JSONTree.Node(children: [], content: .string("root"))
        let tree = JSONTree(root: root)
        let node1 = JSONTree.Node(children: [], content: .bool(true))
        let node2 = JSONTree.Node(children: [], content: .string("test"))
        let node3 = JSONTree.Node(children: [], content: .number(25))
        let node4 = JSONTree.Node(children: [], content: .null(NSNull()))
        let node5 = JSONTree.Node(children: [], content: .string("test child"))
        
        root.children.append(node1)
        root.children.append(node2)
        node1.children.append(node3)
        node1.children.append(node4)
        node2.children.append(node5)
        tree.removeAll(where: { $0.content == .number(25) || $0.content == .string("test child")})
        XCTAssertFalse(tree.contains("test child"))
        XCTAssertFalse(tree.contains(25))
    }
    
    func testRemoveAllMiddleNode() {
        let root = JSONTree.Node(children: [], content: .string("root"))
        let tree = JSONTree(root: root)
        let node1 = JSONTree.Node(children: [], content: .bool(true))
        let node2 = JSONTree.Node(children: [], content: .string("test"))
        let node3 = JSONTree.Node(children: [], content: .number(25))
        let node4 = JSONTree.Node(children: [], content: .null(NSNull()))
        let node5 = JSONTree.Node(children: [], content: .string("test child"))
        let node6 = JSONTree.Node(children: [], content: .string("test"))
        
        root.children.append(node1)
        root.children.append(node2)
        node1.children.append(node3)
        node1.children.append(node4)
        node2.children.append(node5)
        node2.children.append(node6)
        print(tree.prettyFormat)
        XCTAssertTrue(tree.contains("test"))
        XCTAssertEqual(root.children, [node1, node2])
        tree.removeAll(where: { $0.content == .string("test")})
        print(tree.prettyFormat)
        XCTAssertFalse(tree.contains("test"))
        XCTAssertEqual(root.children, [node1, node2.children.first])
    }
    
    func testRemove() {
        let root = JSONTree.Node(children: [], content: .string("root"))
        let tree = JSONTree(root: root)
        let node1 = JSONTree.Node(children: [], content: .bool(true))
        let node2 = JSONTree.Node(children: [], content: .string("test"))
        let node3 = JSONTree.Node(children: [], content: .number(25))
        let node4 = JSONTree.Node(children: [], content: .null(NSNull()))
        let node5 = JSONTree.Node(children: [], content: .string("test child"))
        
        root.children.append(node1)
        root.children.append(node2)
        node1.children.append(node3)
        node1.children.append(node4)
        node2.children.append(node5)
        
        XCTAssertTrue(tree.contains("test"))
        XCTAssertEqual(root.children, [node1, node2])
    }
}
