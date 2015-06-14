import UIKit
import XCTest
import Albatross

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        ActiveRecord.find(1) { result in
            XCTAssert(true, "\(result)")
        }

    }
    
    func testConnection() {
    }
}
