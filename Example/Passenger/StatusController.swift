//
//  ViewController.swift
//  Passenger
//
//  Created by Kellan Cummings on 06/10/2015.
//  Copyright (c) 06/10/2015 Kellan Cummings. All rights reserved.
//

import UIKit
import Passenger

class StatusController: UITableViewController, UITableViewDelegate, UITableViewDataSource, ImageLoadDelegate {

    var statuses = [Status]()
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = user {
            user.profileImageUrl.load(delegate: self)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("statusCell", forIndexPath: indexPath) as! StatusCell
        
        if let text = statuses[indexPath.row].text {
            cell.status.text = text
        }

        if let screenName = statuses[indexPath.row].user.screenName {
            cell.screenName.text = screenName
        }
        
        if let image = user?.profileImageUrl.image {
            cell.avatar.image = image
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statuses.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }
    
    func imageDidLoad(image: Image) {
        dispatch_async(dispatch_get_main_queue()) {
            println("Image Loaded")
            
            self.tableView.reloadData()
        }
    }
    
    func imageDidNotLoad(image: Image) {
        println("Image Did Not Load")
    }
    
}

