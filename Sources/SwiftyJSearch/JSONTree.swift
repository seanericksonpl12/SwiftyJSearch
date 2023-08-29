//
//  JSONTree.swift
//
//  Created by Sean Erickson on 8/28/23.
//  Copyright (c) 2023 Sean Erickson
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import SwiftyJSON
import Foundation

// MARK: - Public Struct and Inits
public struct JSONTree {
    
    private(set) var root: Node
    private var _balanceFactor: Float
    
    /// Initializes an empty tree with the given root node
    init(root: Node) {
        self.root = root
        self._balanceFactor = 0.0
    }
    
    /// Initializes a tree with the given JSON data
    init(json: JSON) {
        self.root = Node(children: [], content: .string("Root"))
        self._balanceFactor = 0.0
        self.buildTree(node: self.root, json: json)
        self.checkBalance()
    }
}


// MARK: - Tree Node
public extension JSONTree {
    
    class Node {
        
        init(children: [Node], content: ContentType, isDictionary: Bool = false) {
            self.children = children
            self.content = content
            self.isDictionary = isDictionary
        }
        
        var children: [Node]
        var content: ContentType
        var isDictionary: Bool
    }
    
    enum ContentType {
        case bool(Bool)
        case string(String)
        case number(NSNumber)
        case null(NSNull)
        
        static func ==(lhs: ContentType, rhs: ContentType) -> Bool {
            switch lhs {
            case .bool(let a):
                switch rhs {
                case .bool(let b):
                    return a == b
                default:
                    return false
                }
            case .string(let a):
                switch rhs {
                case .string(let b):
                    return a == b
                default:
                    return false
                }
            case .number(let a):
                switch rhs {
                case .number(let b):
                    return a == b
                default:
                    return false
                }
            case .null(_):
                switch rhs {
                case .null(_):
                    return true
                default:
                    return false
                }
            }
        }
    }
}


// MARK: - JSON Tree Builder
extension JSONTree {
    
    /// Private recursive worker function to build tree
    private func buildTree(node: Node, json: JSON) {
        switch json.type {
        case .number:
            node.children.append(Node(children: [], content: .number(json.numberValue)))
        case .string:
            node.children.append(Node(children: [], content: .string(json.stringValue)))
        case .bool:
            node.children.append(Node(children: [], content: .bool(json.boolValue)))
        case .array:
            let arr = json.arrayValue
            for val in arr {
                buildTree(node: node, json: val)
            }
        case .dictionary:
            let dictNode = Node(children: [], content: .string("#"), isDictionary: true)
            let sortedDict = json.dictionaryValue.sorted(by: { a, b in
                if let dataA = try? a.value.rawData(), let dataB = try? b.value.rawData() {
                    return dataA.count > dataB.count
                }
                return a.value.count > b.value.count
            })
            node.children.append(dictNode)
            dictNode.children = Array(repeating: Node(children: [], content: .null(NSNull())), count: sortedDict.count)
            var i = 0, j = sortedDict.count - 1
            var swtch = true
            
            for pair in sortedDict {
                let newNode = Node(children: [], content: .string(pair.key))
                if swtch {
                    dictNode.children[i] = newNode
                    i += 1
                } else {
                    dictNode.children[j] = newNode
                    j -= 1
                }
                swtch.toggle()
                buildTree(node: newNode, json: pair.value)
            }
        case .null:
            node.children.append(Node(children: [], content: ContentType.null(NSNull())))
            return
        case .unknown:
            return
        }
    }
}


// MARK: - String Formatting
extension JSONTree {
    
    /// A string representation of the tree, similar in style to the linux 'tree' command.  '#' denotes a dictionary.
    var prettyFormat: String {
        var currentStr: String = ""
        prettyPrinted(currentString: &currentStr, prefix: "", childPrefix: "", child: self.root)
        return currentStr
    }
    
    private func prettyPrinted(currentString: inout String, prefix: String, childPrefix: String, child: Node) {
        currentString.append(prefix)
        switch child.content {
        case .bool(let bool):
            currentString.append(bool.description)
        case .string(let str):
            currentString.append(str)
        case .number(let num):
            currentString.append(num.description)
        case .null(_):
            currentString.append("NULL")
        }
        currentString.append("\n")
        for i in 0..<child.children.count {
            if i != child.children.count - 1 {
                prettyPrinted(currentString: &currentString, prefix: childPrefix + "├── ", childPrefix: childPrefix + "│   ", child: child.children[i])
            } else {
                prettyPrinted(currentString: &currentString, prefix: childPrefix + "└── ", childPrefix: childPrefix + "    ", child: child.children[i])
            }
        }
    }
}


// MARK: - Search
extension JSONTree {
    
    public func search(for value: ContentType) -> Node? {
        let root: Node = self.root
        var queue: [Node] = [root]
        while(!queue.isEmpty) {
            let next = queue.remove(at: 0)
            queue.append(contentsOf: next.children)
            switch value {
            case .bool(let bool):
                if next.content == .bool(bool) { return next }
            case .string(let string):
                if next.content == .string(string) { return next }
            case .number(let nSNumber):
                if next.content == .number(nSNumber) { return next }
            case .null(let nSNull):
                if next.content == .null(nSNull) { return next }
            }
        }
        return nil
    }
}


// MARK: - Contains
public extension JSONTree {
    
    /// Check if a String value is contained in a node of the Tree
    ///
    /// - Parameter value: The String value possibly contained in the tree
    ///
    /// - Returns: True if the Tree contains the value, else false
    func contains(_ value: String) -> Bool { self.contains(.string(value)) }
    
    /// Check if a Bool value is contained in a node of the Tree
    ///
    /// - Parameter value: The Bool value possibly contained in the tree
    ///
    /// - Returns: True if the Tree contains the value, else false
    func contains(_ value: Bool) -> Bool { self.contains(.bool(value)) }
    
    /// Check if a Number value is contained in a node of the Tree
    ///
    /// - Parameter value: The Number value possibly contained in the tree
    ///
    /// - Returns: True if the Tree contains the value, else false
    func contains(_ value: Int) -> Bool { self.contains(.number(value as NSNumber)) }
    
    /// Check if a Number value is contained in a node of the Tree
    ///
    /// - Parameter value: The Number value possibly contained in the tree
    ///
    /// - Returns: True if the Tree contains the value, else false
    func contains(_ value: Float) -> Bool { self.contains(.number(value as NSNumber)) }
    
    /// Check if a Number value is contained in a node of the Tree
    ///
    /// - Parameter value: The Number value possibly contained in the tree
    ///
    /// - Returns: True if the Tree contains the value, else false
    func contains(_ value: Double) -> Bool { self.contains(.number(value as NSNumber)) }
    
    /// private function to convert parameters to ContentType
    private func contains(_ value: ContentType) -> Bool {
        return self.search(for: value) != nil
    }
}


// MARK: - Tree Balancing
extension JSONTree {
    
    
    /// Possibly remove? May not need
    private mutating func checkBalance() {
        let leftCount, rightCount: Int
        var children: [Node] = self.root.children
        while(children.count == 1) {
            if let new = children.first?.children {
                children = new
            } else { break }
        }
        if root.children.count % 2 == 0 {
            leftCount = _sumNodes(Array(children[0..<(children.count / 2)]))
        } else {
            leftCount = _sumNodes(Array(children[0...(children.count / 2)]))
        }
        rightCount = _sumNodes(Array(children[(children.count / 2)..<children.count]))
        
        self._balanceFactor = Float(leftCount) / Float(rightCount)
        print("left sum: \(leftCount)")
        print("right sum: \(rightCount)")
        print(self._balanceFactor)
    }
    
    private func _sumNodes(_ nodes: [Node]) -> Int {
        if nodes.isEmpty { return 0 }
        var sum: Int = 0
        sum += nodes.count
        nodes.forEach { sum += _sumNodes($0.children) }
        return sum
    }
    
    private mutating func rebalanceTree() {
        
    }
}

