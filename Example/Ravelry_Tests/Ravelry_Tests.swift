import UIKit
import XCTest
import Passenger

class Tests: XCTestCase, MediaLoadDelegate {
    let userId = 0
    
    override func setUp() {
        super.setUp()
        if let service = Api.shared("ravelry").getAuthorizationService(AuthorizationType.OAuth1) as? OAuth1 {
            if service.token == nil || service.secret == nil {
                //Set token/secret here to run tests
                service.token = ""
                service.secret = ""
            }
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func mediaDidLoad(media: Passenger.Media) {
        XCTAssert(true, "Image did load, \(media)");
    }
    
    func mediaDidNotLoad(media: Passenger.Media) {
        XCTFail("Image did load, \(media)")
    }
    
    func testFlight() {
        var q = expectationWithDescription("deferred")
        
        RavelryUser.find(userId) { record in
            if let user = record as? RavelryUser {

                //Set username here
                XCTAssert(user.username == "", "\(user.username) not true")
                XCTAssert(user.id == self.userId, "\(user.id)")
                
                user.projects.list { flight in
                    
                    XCTAssert(flight != nil, "No Members in Flight")
                    
                    Project.search(["query": "untitled"]) { flight in
                        
                        XCTAssert(flight != nil, "No Members in Flight")
                        
                        q.fulfill()
                    }
                }
                
            } else {
                XCTAssert(false, "Could Not Locate user \(self.userId)")
                q.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(15) { error in
            XCTAssertNil(error, "Timeout")
        }
    }
    
    func testPassenger() {
        var q = expectationWithDescription("deferred")
        
        RavelryUser.find(userId) { record in
            if let user = record as? RavelryUser {

                //Set username here
                XCTAssert(user.username == "", "\(user.username) not true")
                XCTAssert(user.id == self.userId, "\(user.id)")
                
                if let username = user.username {
                    
                    var params = [
                        "name": "123",
                        "progress": 102,
                        "started": "1983-01-01",
                        "completed": "2015-06-26",
                    ]
                    
                    user.projects.create(params) { record in
                        if let project = record {
                            XCTAssert(project.name! == params["name"], "\(project.name!)")
                            XCTAssert(project.progress == 100, "\(project.progress)")
                            
                            let newProjectName = "new project"
                            project.name = newProjectName
                            
                            
                            project.save { obj in
                                
                                XCTAssert((obj as? Project)?.id ?? 0 == project.id, "Project has not been saved")
                                
                                //println("Project has been saved. \(project.id)")
                                user.projects.find(project.id) { obj in
                                    //println("Project has been found")
                                    if let project = obj {
                                        XCTAssert(project.name! == newProjectName, project.name!)
                                        
                                        project.comments.list { obj in
                                            println("Project Comments: \(obj)")
                                            XCTAssert(true, "")
                                            
                                            if let image = UIImage(named: "test") {
                                                var data = ["test": image]
                                                
                                                project.createPhoto(data) { obj in
                                                    println("Photo Created: \(obj)")
                                                    
                                                    if let json = obj as? [String: AnyObject] {
                                                        
                                                        XCTAssert(json["status_token"] != nil, "No Status Token Returned")
                                                        
                                                        project.destroy { obj in
                                                            XCTAssert((obj as? Project)?.id ?? 0 == project.id, "Project was not destroyed")
                                                            q.fulfill()
                                                        }
                                                        
                                                    } else {
                                                        XCTFail("Image is nil")
                                                        q.fulfill()
                                                    }
                                                }
                                                
                                            } else {
                                                XCTFail("Could not load test image")
                                                q.fulfill()
                                            }
                                        }
                                        
                                    } else {
                                        XCTAssert(false, "Unable to Fetch project \(project.id)")
                                        q.fulfill()
                                    }
                                }
                            }
                        }
                    }
                } else {
                    XCTFail("Unable to locate username")
                    q.fulfill()
                }
            }
        }
        
        waitForExpectationsWithTimeout(15) { error in
            XCTAssertNil(error, "Timeout")
        }
    }
}
