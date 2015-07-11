import UIKit
import XCTest
import Albatross

class Tests: XCTestCase {
    let userId = 4952800
    
    override func setUp() {
        super.setUp()
        if let service = Api.shared.getAuthorizationService(AuthorizationType.OAuth1) as? OAuth1 {
            if service.token == nil || service.secret == nil {
                service.token = "OpuJqmxlvry6z3VEMXOeLNl4Lzln9gWRD8PHEa6X"
                service.secret = "D7BAObzZNdUS2BA6HCfLfILg8BnkDWlAO486ObNT"
            }
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSearch() {

        //["include_entities": true]
        /*
        Status.search(["screen_name": "dril", "count": 1]) { statuses in
        if let statuses = statuses as? [Status] {
        for status in statuses {
        println(status)
        println(status.user)
        }
        } else {
        
        }
        }
        */
        /*
        */
        
        
        
    }
    
    func testFlight() {
        var q = expectationWithDescription("deferred")

        Status.find(618893613221568512) { status in
            //println("<< Testing Status with User Mentions >>")
            if let status = status as? Status {
                //println(status)
                //println(status.user)
                
                if let urls = status.user.model?.entities.model?.url["urls"] {
                    //println(urls)
                }
                
                if let userMentions = status.entities.model?.userMentions {
                    //println(userMentions)
                }
                
                if let profileImageUrl = status.user.model?.profileImageUrl {
                    //println(profileImageUrl)
                }
                
                XCTAssert(true, "Yes")
                q.fulfill()
            }
            /*
            //println("<< Testing Status with Hashtags and Media >>")
            Status.find(587738967279325184) { status in
            if let status = status as? Status {
            if let hashtags = status.entities.model?.hashtags {
            //println(hashtags)
            }
            
            if let media = status.entities.model?.media {
            //println(media)
            }
            }
            }
            */
        }

        waitForExpectationsWithTimeout(10) { error in
            XCTAssertNil(error, "Timeout")
        }

    }
}