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
    
    var root: Node
    
    /// Initializes an empty tree with the given root node
    init(root: Node) {
        self.root = root
    }
    
    /// Initializes a tree with the given JSON data
    init(json: JSON) {
        self.root = Node(children: [], content: .string("Root"))
        self.buildTree(node: self.root, json: json)
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
            let dict = json.dictionaryValue
            let dictNode = Node(children: [], content: .string("#"), isDictionary: true)
            node.children.append(dictNode)
            for pair in dict {
                let newNode = Node(children: [], content: .string(pair.key))
                dictNode.children.append(newNode)
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
