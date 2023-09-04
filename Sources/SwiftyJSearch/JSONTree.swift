//
//  JSONTree.swift
//
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

import Foundation

// MARK: - Public Struct and Inits
public struct JSONTree {
    
    private(set) var root: Node
    private var _balanceFactor: Float
    
    /// Initializes a tree with an empty root node
    init() {
        self.root = Node(children: [], content: .null)
        self._balanceFactor = 0.0
    }
    
    /// Initializes an empty tree with the given root node
    ///
    /// - Parameter root: A JSONTree node to use as the root of the tree
    init(root: Node) {
        self.root = root
        self._balanceFactor = 0.0
    }
    
    /// Initializes a tree from the given JSON data
    ///
    /// - Note: Dictionaries may be reordered to balance the Tree as JSON dictionaries are unordered.
    ///
    /// - Parameter json: A SwiftyJSON JSON Object
    init(json: JSON) {
        self.root = Node(children: [], content: .string("Root"))
        self._balanceFactor = 0.0
        self.buildTree(node: self.root, json: json)
        self.checkBalance()
    }
}


// MARK: - Tree Node
public extension JSONTree {
    
    /// JSONTree Node
    class Node: Equatable {
        
        var children: [Node]
        var content: ContentType
        var isDictionary: Bool
        
        private(set) var id: UUID = UUID()
        
        /// Creates a JSONTree Node instance with given children and content
        /// - Parameters:
        ///    - chilren: array of child nodes
        ///    - content: the value the node stores
        init(children: [Node], content: ContentType) {
            self.children = children
            self.content = content
            self.isDictionary = false
        }
        
        /// Internal Init with option for making the node a dictionary node
        internal init(children: [Node], content: ContentType, isDictionary: Bool = false) {
            self.children = children
            self.content = content
            self.isDictionary = isDictionary
        }
        
        public static func ==(lhs: Node, rhs: Node) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    internal class _BreakNode: Node {
        convenience init() {
            self.init(children: [], content: .string("BREAK_NODE"))
        }
    }
    
    enum ContentType {
        case bool(Bool)
        case string(String)
        case number(NSNumber)
        case null
        
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
            case .null:
                switch rhs {
                case .null:
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
            dictNode.children = Array(repeating: Node(children: [], content: .null), count: sortedDict.count)
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
            node.children.append(Node(children: [], content: ContentType.null))
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
        case .null:
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
public extension JSONTree {
    
    /// Search for a node with the given value as content
    ///
    /// - Parameter value: The String value to search for
    /// - Returns: The node if found, else nil
    func search(for value: String) -> Node? { self.search(for: .string(value)) }
    
    /// Search for a node with the given value as content
    ///
    /// - Parameter value: The Bool value to search for
    /// - Returns: The node if found, else nil
    func search(for value: Bool) -> Node? { self.search(for: .bool(value)) }
    
    /// Search for a node with the given value as content
    ///
    /// - Parameter value: The Int value to search for
    /// - Returns: The node if found, else nil
    func search(for value: Int) -> Node? { self.search(for: .number(value as NSNumber)) }
    
    /// Search for a node with the given value as content
    ///
    /// - Parameter value: The Float value to search for
    /// - Returns: The node if found, else nil
    func search(for value: Float) -> Node? { self.search(for: .number(value as NSNumber)) }
    
    /// Search for a node with the given value as content
    ///
    /// - Parameter value: The Double value to search for
    /// - Returns: The node if found, else nil
    func search(for value: Double) -> Node? { self.search(for: .number(value as NSNumber)) }
    
    private func search(for value: ContentType) -> Node? {
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
            case .null:
                if next.content == .null { return next }
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
    /// - Returns: True if the Tree contains the value, else false
    func contains(_ value: String) -> Bool { self.contains(.string(value)) }
    
    /// Check if a Bool value is contained in a node of the Tree
    ///
    /// - Parameter value: The Bool value possibly contained in the tree
    /// - Returns: True if the Tree contains the value, else false
    func contains(_ value: Bool) -> Bool { self.contains(.bool(value)) }
    
    /// Check if a Number value is contained in a node of the Tree
    ///
    /// - Parameter value: The Number value possibly contained in the tree
    /// - Returns: True if the Tree contains the value, else false
    func contains(_ value: Int) -> Bool { self.contains(.number(value as NSNumber)) }
    
    /// Check if a Number value is contained in a node of the Tree
    ///
    /// - Parameter value: The Number value possibly contained in the tree
    /// - Returns: True if the Tree contains the value, else false
    func contains(_ value: Float) -> Bool { self.contains(.number(value as NSNumber)) }
    
    /// Check if a Number value is contained in a node of the Tree
    ///
    /// - Parameter value: The Number value possibly contained in the tree
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
    internal mutating func checkBalance() {
        let leftCount, rightCount: Int
        var children: [Node] = self.root.children
        while(children.count == 1) {
            if let new = children.first?.children {
                children = new
            } else { break }
        }
        if children.count % 2 == 0 {
            leftCount = _sumNodes(Array(children[0..<(children.count / 2)]))
        } else {
            leftCount = _sumNodes(Array(children[0...(children.count / 2)]))
        }
        rightCount = _sumNodes(Array(children[(children.count / 2)..<children.count]))
        
        self._balanceFactor = Float(leftCount) / Float(rightCount)
    }
    
    private func _sumNodes(_ nodes: [Node]) -> Int {
        if nodes.isEmpty { return 0 }
        var sum: Int = 0
        sum += nodes.count
        nodes.forEach { sum += _sumNodes($0.children) }
        return sum
    }
}


// MARK: - Count
extension JSONTree {
    
    public var count: Int { self._count() }
    public var contentNodeCount: Int { self._contentNodeCount() }
    
    internal func _count() -> Int {
        var count = 1
        var queue = [self.root]
        while(!queue.isEmpty) {
            let next = queue.remove(at: 0)
            queue.append(contentsOf: next.children)
            count += 1
        }
        return count
    }
    
    internal func _contentNodeCount() -> Int {
        var count = 1
        var queue = [self.root]
        while(!queue.isEmpty) {
            let next = queue.remove(at: 0)
            queue.append(contentsOf: next.children)
            if !next.isDictionary { count += 1 }
        }
        return count
    }
}


// MARK: - Remove
public extension JSONTree {
    
    /// Private helper to remove a node from the tree
    internal func _remove(node: Node, parent: Node) -> Bool {
        guard let index = parent.children.firstIndex(of: node) else { return false }
        parent.children.remove(at: index)
        parent.children.append(contentsOf: node.children)
        return true
    }
    
    /// Remove a given node from the tree
    ///
    /// - Parameter node: The node to remove
    /// - Returns: True if node was removed, else false
    func remove(node toRemove: Node) -> Bool {
        var queue = [self.root]
        var possibleParent: Node?
        while(!queue.isEmpty) {
            let next = queue.remove(at: 0)
            if next.children.contains(toRemove) {
                possibleParent = next
                break
            }
            queue.append(contentsOf: next.children)
        }
        guard let parent = possibleParent else { return false }
        return self._remove(node: toRemove, parent: parent)
    }
    
    /// Remove all nodes that satify a given predicate
    ///
    /// - Note: Root cannot be removed
    /// - Parameter where: Node to Bool closure.  If a node returns true in the closure, it will be removed
    func removeAll(where exp: (Node) throws -> Bool) rethrows {
        var toRemove: [(Node, Node)] = []
        var queue: [Node] = [self.root]
        var parentQueue: [Node] = []
        while(!queue.isEmpty) {
            let next = queue.remove(at: 0)
            if next is _BreakNode {
                if !parentQueue.isEmpty { parentQueue.remove(at: 0) }
            } else {
                queue.append(contentsOf: next.children)
                queue.append(_BreakNode())
                if let check = try? exp(next), check == true {
                    if let parent = parentQueue.first {
                        toRemove.insert((next, parent), at: 0)
                    }
                }
                parentQueue.append(next)
            }
        }
        toRemove.forEach {let _ = self._remove(node: $0.0, parent: $0.1) }
    }
}


// MARK: - Convert to JSON
extension JSONTree {
    
    /// Internal for now until polished
    internal func convertToJSON() -> JSON {
        buildJSON(node: self.root, json: JSON())
    }
    
    private func buildJSON(node: Node, json: JSON) -> JSON {
        if node.children.isEmpty {
            switch node.content {
            case .bool(let bool):
                return JSON(booleanLiteral: bool)
            case .string(let str):
                return JSON(stringLiteral: str)
            case .number(let num):
                return JSON(floatLiteral: FloatLiteralType(truncating: num))
            case .null:
                return JSON(rawValue: NSNull()) ?? JSON()
            }
        }
        else if node.isDictionary {
            var dictionary: [String : Any] = [:]
            node.children.forEach {
                switch $0.content {
                case .bool(_):
                    break
                case .string(let str):
                    if $0.children.count == 1 {
                        dictionary[str] = buildJSON(node: $0.children.first!, json: json)
                    } else {
                        dictionary[str] = buildJSON(node: $0, json: json)
                    }
                case .number(_):
                    break
                case .null:
                    break
                    
                }
            }
            return JSON(dictionary)
        } else {
            var arr: [JSON] = []
            node.children.forEach { arr.append(buildJSON(node: $0, json: json)) }
            return JSON(arr)
        }
    }
}
