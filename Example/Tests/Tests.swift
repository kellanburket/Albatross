import UIKit
import XCTest
import Passenger

class Tests: XCTestCase, ImageLoadDelegate {

    let userId = 4952800
    var q: XCTestExpectation? = nil
    
    override func setUp() {
        super.setUp()
        if let service = Api.shared("twitter").getAuthenticationService(AuthenticationType.OAuth1) as? OAuth1 {
            if service.token == nil || service.secret == nil {
                service.token = "OpuJqmxlvry6z3VEMXOeLNl4Lzln9gWRD8PHEa6X"
                service.secret = "D7BAObzZNdUS2BA6HCfLfILg8BnkDWlAO486ObNT"
            }
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }

    /*
    func testSearch() {
        var q = expectationWithDescription("deferred")

        Status.search(["screen_name": "dril", "count": 10]) { statuses in
            if let statuses = statuses as? [Status] {
                for status in statuses {
                    println(status)
                    println(status.user)
                }
            } else {
            
            }
        }
        
        XCTAssert(true, "Yes")
        q.fulfill()

        waitForExpectationsWithTimeout(10) { error in
            XCTAssertNil(error, "Timeout")
        }

    }

    func testFlight() {
        var q = expectationWithDescription("deferred")

        Status.find(618893613221568512) { status in
            //println("\n\n<< Testing Status with User Mentions >>")
            if let status = status as? Status {
                //println(status)
                //println(status.user)
                
                if let urls = status.user.model?.entities.model?.url["urls"] {
                    //println(urls)
                }
                
                if let userMentions = status.entities.model?.userMentions {
                    for userMention in userMentions {
                        //println(userMention)
                    }
                }
                
                if let profileImageUrl = status.user.model?.profileImageUrl {
                    //println(profileImageUrl)

                }
                
                XCTAssert(true, "Yes")
            }
        }

        waitForExpectationsWithTimeout(10) { error in
            XCTAssertNil(error, "Timeout")
        }
    }
    */
    

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
        }

        waitForExpectationsWithTimeout(10) { error in
            XCTAssertNil(error, "Timeout")
        }
    }
    
    func imageDidNotLoad(image: Image) {
        XCTAssert(false, "Image Did Not Load")
        q?.fulfill()
    }
    
    func imageDidLoad(image: Image) {
        XCTAssert(true, "Image Did Load")
        q?.fulfill()
    }
}