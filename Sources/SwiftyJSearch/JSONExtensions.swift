//
//  JSONExtensions.swift
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
            currentString.append(child.stringValue.replacingOccurrences(of: "\n", with: "\n" + childPrefix))
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

// MARK: - BFS
extension JSON {
    
    public enum SearchOptions {
        case all
        case first
        case last
    }
}

public extension JSON {
    
    /// Breadth First Search of a JSON object to find values for specific keys
    ///
    /// - Warning: JSON Dictionaries are unordered, using .first or .last may result in different values each function call if the found values are nested at the same depth
    ///
    /// - Parameters:
    ///    - keys: The keys to search for
    ///    - excluding: Optional keys to exclude in the search to improve performance
    ///    - returning: Which matches to return - all of them, first, or last
    ///    - maxDepth: The maximum depth of traversal during the search
    ///
    /// - Returns: A string to JSON array dictionary of each found key matching to its corresponding array of JSON values
    func bfs(for keys: [String],
             excluding: [String] = [],
             returning: SearchOptions = .all,
             maxDepth: Int? = nil) -> [String : [JSON]] {
        self.bfs(keys: keys, excluding: excluding, returning: returning, maxDepth: maxDepth)
    }
    
    /// Breadth First Search of a JSON object to find values for  a specific key
    ///
    /// - Warning: JSON Dictionaries are unordered, using .first or .last may result in different values each function call if the found values are nested at the same depth
    ///
    /// - Parameters:
    ///    - key: The key to search for
    ///    - excluding: Optional keys to exclude in the search to improve performance
    ///    - returning: Which matches to return - all of them, first, or last
    ///    - maxDepth: The maximum depth of traversal during the search
    ///
    /// - Returns: Array of the JSON values of the found key, or an empty array if the key is not found
    func bfs(for key: String,
             excluding: [String] = [],
             returning: SearchOptions = .all,
             maxDepth: Int? = nil) -> [JSON] {
        self.bfs(keys: [key], excluding: excluding, returning: returning, maxDepth: maxDepth).values.first ?? []
    }
    
    /// Private worker function to do the search
    private func bfs(keys: [String],
                     excluding: [String],
                     returning: SearchOptions,
                     maxDepth: Int?) -> [String : [JSON]] {
        
        var rtrnDict = [String: [JSON]]()
        var queue: [JSON] = []
        var depth = 0
        queue.append(self)
        while(!queue.isEmpty) {
            if let max = maxDepth, depth > max { break }
            if returning == .first && keys.count <= rtrnDict.values.count { break }
            let cur = queue.remove(at: 0)
            let arr = cur.arrayValue
            let dict = cur.dictionaryValue
            
            if !arr.isEmpty {
                queue.append(contentsOf: arr)
            }
            else if !dict.isEmpty {
                for i in keys {
                    if let val = dict[i], rtrnDict[i] == nil {
                        rtrnDict[i] = [val]
                    } else if let val = dict[i], rtrnDict[i] != nil {
                        switch returning {
                        case .all:
                            rtrnDict[i]?.append(val)
                        case .first:
                            if keys.count <= rtrnDict.values.count {
                                return rtrnDict
                            }
                        case .last:
                            rtrnDict[i] = [val]
                        }
                    }
                }
                
                dict.forEach {
                    if !excluding.contains($0.key) {
                        queue.append($0.value)
                    }
                }
            }
            depth += 1
        }
        
        return rtrnDict
    }
}


// MARK: - Depth First Search
extension JSON {
    
    /// Depth First Search of a JSON object to find values for specific keys
    ///
    /// - Warning: JSON Dictionaries are unordered, using .first or .last may result in different values each function call if the found values are nested at the same depth
    ///
    /// - Parameters:
    ///    - keys: The keys to search for
    ///    - excluding: Optional keys to exclude in the search to improve performance
    ///    - returning: Which matches to return - all of them, first, or last
    ///    - maxDepth: The maximum depth of traversal during the search
    ///
    /// - Returns: A string to JSON array dictionary of each found key matching to its corresponding array of JSON values
    func dfs(for keys: [String],
             excluding: [String] = [],
             returning: SearchOptions = .all,
             maxDepth: Int? = nil) -> [String : [JSON]] {
        var returnDict: [String : [JSON]] = [:]
        self.dfs(keys: keys,
                 excluding: excluding,
                 returning: returning,
                 maxDepth: maxDepth,
                 json: self,
                 returnDict: &returnDict)
        return returnDict
    }
    
    /// Depth First Search of a JSON object to find values for  a specific key
    ///
    /// - Warning: JSON Dictionaries are unordered, using .first or .last may result in different values each function call if there are multiple of the same key
    ///
    /// - Parameters:
    ///    - key: The key to search for
    ///    - excluding: Optional keys to exclude in the search to improve performance
    ///    - returning: Which matches to return - all of them, first, or last
    ///    - maxDepth: The maximum depth of traversal during the search
    ///
    /// - Returns: Array of the JSON values of the found key, or an empty array if the key is not found
    func dfs(for key: String,
             excluding: [String] = [],
             returning: SearchOptions = .all,
             maxDepth: Int? = nil) -> [JSON] {
        var returnDict: [String : [JSON]] = [:]
        self.dfs(keys: [key],
                 excluding: excluding,
                 returning: returning,
                 maxDepth: maxDepth,
                 json: self,
                 returnDict: &returnDict)
        return returnDict.values.first ?? []
    }
    
    /// Recursive worker function to do the searching
    private func dfs(keys: [String],
                     excluding: [String] = [],
                     returning: SearchOptions = .all,
                     maxDepth: Int? = nil,
                     json: JSON,
                     returnDict: inout [String : [JSON]]) {
        
        switch json.type {
        case .number:
            return
        case .string:
            return
        case .bool:
            return
        case .array:
            json.arrayValue.forEach {
                dfs(keys: keys,
                    excluding: excluding,
                    returning: returning,
                    maxDepth: maxDepth,
                    json: $0,
                    returnDict: &returnDict)
            }
        case .dictionary:
            let dict = json.dictionaryValue
            for (key, value) in dict {
                if excluding.contains(key) { continue }
                if keys.contains(key) {
                    switch returning {
                    case .all:
                        if returnDict[key] == nil {
                            returnDict[key] = [value]
                        } else {
                            returnDict[key]?.append(value)
                        }
                    case .first:
                        if returnDict[key] == nil {
                            returnDict[key] = [value]
                        }
                    case .last:
                        returnDict[key] = [value]
                    }
                }
                dfs(keys: keys,
                    excluding: excluding,
                    returning: returning,
                    maxDepth: maxDepth,
                    json: value,
                    returnDict: &returnDict)
            }
        case .null:
            return
        case .unknown:
            return
        }
    }
}
