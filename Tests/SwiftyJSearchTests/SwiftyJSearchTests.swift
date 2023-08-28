import XCTest
import SwiftyJSON
@testable import SwiftyJSearch

final class SwiftyJSearchTests: XCTestCase {
    
    var family: JSON!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.family = [
            "names": [
                "Brooke Abigail Matos",
                "Rowan Danger Matos"
            ],
            "motto": "Hey, I don't know about you, but I'm feeling twenty-two! So, release the KrakenDev!"
        ]
    }
    
    func testBfs() {
        let nestedFamily: JSON = [
            "count": 1,
            "families": [
                [
                    "isACoolFamily": true,
                    "family": [
                        "hello": family
                    ]
                ],
                [
                    "second list": true,
                    "has more stuff": true,
                    "second family": [
                        "names": [
                            "Sean Erickson"
                        ],
                        "motto": "Hey, I don't know about you, but I'm feeling twenty-two! So, release the KrakenDev!"
                    ]
                ]
            ]
        ]
        print(try? nestedFamily.bfs(for: "names", returning: .first))
    }
}
