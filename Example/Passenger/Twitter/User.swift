//
//  User.swift
//  Passenger
//
//  Created by Kellan Cummings on 7/9/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation
import Passenger

class User: Model {
    var idStr: String?
    var name: String?
    var screenName: String?
    var location: String?
    var url: NSURL?
    
    var entities = UserEntity()
    
    var protected: Bool = false
    var followersCount = Int()
    var friendsCount = Int()
    var listedCount = Int()
    var createdAt: NSDate?
    var favoritesCount = Int()
    var profileBackgroundImageUrl = Image()

    var profileImageUrl = Image()
    var profileImageUrlHttps = Image()
    
    var profileLinkColor: UIColor?
    var profileSidebareColor: UIColor?
    var profileTextColor: UIColor?

    var status = BelongsTo<Status>()

    class func lookup(params: Json, onComplete: [User]? -> Void) {
        self.doAction("lookup", params: params) { (objs: [Model]?) in
            if let objs = objs as? [User] {
                onComplete(objs)
            } else {
                onComplete(nil)
            }
        }
    }

}