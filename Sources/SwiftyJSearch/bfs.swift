//
//  bfs.swift
//
//  Created by Sean Erickson on 8/27/23.
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
    
    public enum SearchOptions {
        case all
        case first
        case last
    }
}

public extension JSON {
    
    /// Breadth First Search of a JSON object to find values for specific keys
    ///
    /// - Parameters:
    ///    - keys: The keys to search for
    ///    - excluding: optional keys to exclude in the search to improve performance
    ///    - maxDepth: The maximum depth of traversal during the search
    ///
    /// - Returns: A string to JSON dictionary of each found key matching to its corresponding JSON value
    func bfs(for keys: [String],
                    excluding: [String] = [],
                    returning: SearchOptions = .first,
                    maxDepth: Int? = nil) -> [String : [JSON]] {
        self.bfs(keys: keys, excluding: excluding, returning: returning, maxDepth: maxDepth)
    }
    
    /// Breadth First Search of a JSON object to find values for  a specific key
    ///
    /// - Parameters:
    ///    - key: The key to search for
    ///    - excluding: optional keys to exclude in the search to improve performance
    ///    - maxDepth: The maximum depth of traversal during the search
    ///
    /// - Returns: The JSON value of the found key, or nil if the key is not found
    func bfs(for key: String,
                    excluding: [String] = [],
                    returning: SearchOptions = .all,
                    maxDepth: Int? = nil) -> [JSON] {
        self.bfs(keys: [key], excluding: excluding, returning: returning, maxDepth: maxDepth).values.first ?? []
    }
    
    /// Private worker function to do the search
    fileprivate func bfs(keys: [String],
                         excluding: [String],
                         returning: SearchOptions,
                         maxDepth: Int?) -> [String : [JSON]] {
        
        var rtrnDict = [String: [JSON]]()
        var queue: [JSON] = []
        var depth = 0
        queue.append(self)
        while(!queue.isEmpty) {
            if let max = maxDepth, depth > max { break }
            if returning == .first && keys.count <= rtrnDict.values.count {
                print("rtrn dict: \(rtrnDict)")
                print("rtrn dict count: \(rtrnDict.count)")
                break
            }
            let cur = queue.remove(at: 0)
            let arr = cur.arrayValue
            let dict = cur.dictionaryValue
            
            if !arr.isEmpty {
                queue.append(contentsOf: arr)
            }
            else if !dict.isEmpty {
                keys.forEach {
                    if let val = dict[$0], rtrnDict[$0] == nil {
                        rtrnDict[$0] = [val]
                    } else if let val = dict[$0], rtrnDict[$0] != nil {
                        switch returning {
                        case .all:
                            rtrnDict[$0]?.append(val)
                        case .first:
                            break
                        case .last:
                            rtrnDict[$0] = [val]
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