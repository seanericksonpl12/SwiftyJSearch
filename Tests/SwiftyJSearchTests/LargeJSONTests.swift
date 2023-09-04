//
//  LargeJSONTests.swift
//  
//
//  Created by Sean Erickson on 9/2/23.
//

import XCTest
import Combine
@testable import SwiftyJSearch
final class LargeJSONTests: XCTestCase {

    var json: JSON!
    var cancellables: Set<AnyCancellable>!
    var wait: XCTestExpectation!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.wait = XCTestExpectation()
        self.cancellables = Set<AnyCancellable>()
        let session = URLSession(configuration: .default)
        session.dataTaskPublisher(for: URL(string: "https://api.github.com/events")!)
            .tryMap(\.data)
            .tryMap { try JSON(data: $0) }
            .eraseToAnyPublisher()
            .sink { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    XCTFail("failure: \(error)")
                }
            } receiveValue: {
                self.json = $0
                self.wait.fulfill()
            }
            .store(in: &cancellables)
    }
    
    func testSearchAll() {
        wait(for: [wait], timeout: 5)
        let results = json.bfs(for: "actor", returning: .all)
        XCTAssertEqual(results.count, 30)
    }
    
    func testBuildTree() {
        wait(for: [wait], timeout: 5)
        let tree = JSONTree(json: self.json)
        let json2 = tree.convertToJSON()
        var results1 = self.json.bfs(for: "actor", returning: .all)
        var results2 = json2.bfs(for: "actor", returning: .all)
        results1.sort()
        results2.sort()
        XCTAssertEqual(results1, results2)
    }

}
