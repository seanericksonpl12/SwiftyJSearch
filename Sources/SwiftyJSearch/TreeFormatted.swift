//
//  TreeFormatted.swift
//
//  Created by Sean Erickson on 8/29/23.
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

extension JSON {
    
    /// A tree-style string representation of the JSON, similar in style to the linux 'tree' command.  '#' denotes a dictionary.
    public var treeFormat: String {
        var current: String = ""
        self.prettyPrinted(currentString: &current,
                           prefix: "",
                           childPrefix: "",
                           child: self)
        return current
    }
}

extension JSON {
    
    /// Recursive String Cat function to build the tree structure
    private func prettyPrinted(currentString: inout String,
                               prefix: String,
                               childPrefix: String,
                               child: JSON,
                               previousDictionary: Bool = false) {
        switch child.type {
        case .number:
            currentString.append(prefix)
            currentString.append(child.numberValue.description)
            currentString.append("\n")
        case .string:
            currentString.append(prefix)
            currentString.append(child.stringValue)
            currentString.append("\n")
        case .bool:
            currentString.append(prefix)
            currentString.append(child.boolValue.description)
            currentString.append("\n")
        case .array:
            for i in 0..<child.arrayValue.count {
                if i != child.arrayValue.count - 1 {
                    prettyPrinted(currentString: &currentString,
                                  prefix: childPrefix + "├── ",
                                  childPrefix: previousDictionary ? (childPrefix + "│") : (childPrefix + "│   "),
                                  child: child.arrayValue[i])
                } else {
                    prettyPrinted(currentString: &currentString,
                                  prefix: childPrefix + "└── ",
                                  childPrefix: previousDictionary ? childPrefix : (childPrefix + "    "),
                                  child: child.arrayValue[i])
                }
            }
        case .dictionary:
            let dict = child.dictionaryValue
            if dict.count > 1 {
                currentString.append(prefix)
                currentString.append("#")
                currentString.append("\n")
                let arr: [[String : JSON]] = Array(child.dictionaryValue).map { [$0.key : $0.value] }
                let newChild = JSON(arrayLiteral: arr)
                prettyPrinted(currentString: &currentString,
                              prefix: childPrefix + "└── ",
                              childPrefix: childPrefix,
                              child: newChild,
                              previousDictionary: true)
            } else {
                if let pair = dict.first {
                    currentString.append(prefix)
                    currentString.append(pair.key)
                    currentString.append("\n")
                    prettyPrinted(currentString: &currentString,
                                  prefix: childPrefix + "└── ",
                                  childPrefix: childPrefix + "    ",
                                  child: pair.value)
                }
            }
        case .null:
            currentString.append(prefix)
            currentString.append("NULL")
            currentString.append("\n")
        case .unknown:
            break
        }
    }
}
