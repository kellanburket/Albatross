//
//  User.swift
//  Albatross
//
//  Created by Kellan Cummings on 6/27/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation
import Albatross

class User: Passenger {
    var location: String?
    var username: String?
    var faveCurse: String?
    var aboutMe: String?
    var firstName: String?
    
    lazy var projects: HasManyRelationship<Project> = {
        return HasManyRelationship<Project>(self)
    }()
    
    //"large_photo_url": "http://avatars.ravelry.com/kellanbc/286360009/kellan-pic_xlarge.jpg",
    //"photo_url": "http://avatars.ravelry.com/kellanbc/286360009/kellan-pic_large.jpg",
    //"small_photo_url": "http://avatars.ravelry.com/kellanbc/286360009/kellan-pic_small.jpg",
    //"tiny_photo_url": "http://avatars.ravelry.com/kellanbc/286360009/kellan-pic_tiny.jpg",
}