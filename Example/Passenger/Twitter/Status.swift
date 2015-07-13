//
//  Status.swift
//  Passenger
//
//  Created by Kellan Cummings on 7/7/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation
import Passenger

class Status: Model {

    var screenName: String?
    var text: String?

    var entities = StatusEntity()

    var coordinates: String?
    
    var favorited = Bool()
    var truncated = Bool()
    
    var createdAt: NSDate?
    
    var indices = [Int]()
    
    var user = User()
    
    var retweetCount = Int()
    var favoriteCount = Int()

    var inReplyToStatusId = Int()
    var inReplyToStatusIdStr = String()
    var inReplyToUserId = Int()
    var inReplyToUserIdStr = String()
    var inReplyToUserScreenName = String()
    
    class func user(params: Json, onComplete: [Status]? -> Void) {
        self.search(params) { obj in
            if let tweets = obj as? [Status] {
                onComplete(tweets)
            } else {
                onComplete(nil)
            }
        }
    }

    class func home(params: Json, onComplete: [Status]? -> Void) {
        self.doAction("home", params: params) { (obj: [Model]?) in
            if let tweets = obj as? [Status] {
                onComplete(tweets)
            } else {
                onComplete(nil)
            }
        }
    }
    
    class func mentions(params: Json, onComplete: [Status]? -> Void) {
        self.doAction("mentions", params: params) { (obj: [Model]?) in
            if let tweets = obj as? [Status] {
                onComplete(tweets)
            } else {
                onComplete(nil)
            }
        }
    }
}