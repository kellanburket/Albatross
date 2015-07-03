import UIKit
import XCTest
import Albatross

class Tests: XCTestCase {
    let userId = 4952800
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testFlight() {
        var q = expectationWithDescription("deferred")
        
        User.find(userId) { record in
            if let user = record as? User {
                XCTAssert(user.username == "kellanbc", "\(user.username) not true")
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
                        "started": "01/06/1983",
                        "completed": "06/26/2015",
                    ]
                    
                    user.projects.create(params) { record in
                        if let project = record {
                            XCTAssert(project.name! == params["name"], "\(project.name!)")
                            XCTAssert(project.progress == 100, "\(project.progress)")
                            let startDate = project.started!.format("MM/dd/yyyy")
                            XCTAssert(startDate == params["started"]!, startDate)
                            let completedDate = project.completed!.format("MM/dd/yyyy")
                            
                            XCTAssert(completedDate == params["completed"]!, completedDate)
                            
                            let newProjectName = "new project"
                            project.name = newProjectName
                            
                            project.save { success in
                                XCTAssert(success, "Project has not been saved")

                                if success {
                                    //println("Project has been saved. \(project.id)")
                                    user.projects.find(project.id) { obj in
                                        //println("Project has been found")
                                        if let record = obj {
                                            XCTAssert(record.name! == newProjectName, record.name!)
                                            
                                            project.destroy { success in
                                                XCTAssert(success, "Project was not destroyed")
                                                q.fulfill()
                                            }
                                            
                                        } else {
                                            XCTAssert(false, "Unable to Fetch project \(project.id)")
                                            q.fulfill()
                                        }
                                    }
                                } else {
                                    q.fulfill()
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
        
        waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "Timeout")
        }
    }
}