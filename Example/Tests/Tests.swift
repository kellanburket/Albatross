import UIKit
import XCTest
import Passenger

class Tests: XCTestCase, MediaLoadDelegate {

    let userId = 4952800
    var q: XCTestExpectation? = nil
    
    override func setUp() {
        super.setUp()
        if let service = Api.shared().getAuthorizationService(AuthorizationType.OAuth1) as? OAuth1 {
            if service.token == nil || service.secret == nil {
                //Set test tokens here
                service.token = ""
                service.secret = ""
            }
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSearch() {
        var q = expectationWithDescription("deferred")

        Status.search(["screen_name": "dril", "count": 10]) { statuses in
            if let statuses = statuses as? [Status] {
                for status in statuses {
                    println(status)
                    println(status.user)
                }
                XCTAssert(true, "Loaded Statuses.")
            } else {
                XCTAssert(false, "Could not search statuses.")
            }

            q.fulfill()
        }
        

        waitForExpectationsWithTimeout(10) { error in
            XCTAssertNil(error, "Timeout")
        }

    }

    func testMedia() {
        q = expectationWithDescription("deferred")
        
        //println("<< Testing Status with Hashtags and Media >>")
        Status.find(587738967279325184) { status in

            if let status = status as? Status {
            
                //println("Hashtags: \(status.entities.hashtags.count)")
                for hashtag in status.entities.hashtags {
                    //println(hashtag)
                }

                //println("Media: \(status.entities.media.count)")
                for medium in status.entities.media {
                    //println(medium)
                    //println(medium.url)
                    medium.mediaUrlHttps.load(delegate: self)
                }
                
                XCTAssert(true, "Status Object was constructed.")
            } else {
                XCTAssert(false, "Could not construct Status Object")
            }            

            self.q?.fulfill()
        }

        waitForExpectationsWithTimeout(15) { error in
            XCTAssertNil(error, "Timeout")
        }
    }
    
    func mediaDidNotLoad(image: Passenger.Media) {
        XCTAssert(false, "Image Did Not Load")
    }
    
    func mediaDidLoad(image: Passenger.Media) {
        XCTAssert(true, "Image Did Load")
    }
}