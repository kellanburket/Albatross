import UIKit
import XCTest
import Albatross

class Tests: XCTestCase, ImageLoadDelegate {
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
    
    func imageDidLoad(image: Image) {
        XCTAssert(true, "Image did load, \(image)");
    }

    func imageDidNotLoad(image: Image) {
        XCTFail("Image did load, \(image)")
    }

    func testFlight() {
        var q = expectationWithDescription("deferred")
        
        User.find(userId) { record in
            if let user = record as? User {
                XCTAssert(user.username == "kellanbc", "\(user.username) not true")
                XCTAssert(user.id == self.userId, "\(user.id)")

                //user.largePhotoUrl?.load(delegate: self)
                //user.smallPhotoUrl?.load(delegate: self)
                //user.photoUrl?.load(delegate: self)
                //user.tinyPhotoUrl?.load(delegate: self)
                
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

        waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "Timeout")
        }
    }
    
    func testPassenger() {
        var q = expectationWithDescription("deferred")
        
        User.find(userId) { record in
            println("User has been identified")
            if let user = record as? User {
                XCTAssert(user.username == "kellanbc", "\(user.username) not true")
                XCTAssert(user.id == self.userId, "\(user.id)")


                if let username = user.username {
                    
                    var params = [
                        "name": "purlie",
                        "progress": 102,
                        "started": "1983-01-06",
                        "completed": "2015-06-26",
                    ]
                    
                    user.projects.create(params) { record in
                        if let project = record {
                            XCTAssert(project.name! == params["name"], "\(project.name!)")
                            XCTAssert(project.progress == 100, "\(project.progress)")
                            let startDate = project.started!.format("yyyy-MM-dd")
                            XCTAssert(startDate == params["started"]!, "Start dates don't match")
                            let completedDate = project.completed!.format("yyyy-MM-dd")

                            XCTAssert(completedDate == params["completed"]!, "End dates don't match")
                            
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
                                                    
                                                    if let json = obj as? Json {
                                                        
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
        
        waitForExpectationsWithTimeout(10) { error in
            XCTAssertNil(error, "Timeout")
        }
    }
}