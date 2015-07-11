//
//  User.swift
//  Albatross
//
//  Created by Kellan Cummings on 7/9/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation
import Albatross

class User: Passenger {
    var idStr: String?
    var name: String?
    var screenName: String?
    var location: String?
    //var description: String?
    var url: NSURL?
    
    var entities = HasOne<UserEntity>()
    
    var protected: Bool = false
    var followersCount = Int()
    var friendsCount = Int()
    var listedCount = Int()
    var createdAt: NSDate?
    var favoritesCount = Int()
    var profileBackgroundImageUrl: Image?
    var profileImageUrl: Image?
    var profileLinkColor: UIColor?
    var profileSidebareColor: UIColor?
    var profileTextColor: UIColor?

    var status = BelongsTo<Status>()
}