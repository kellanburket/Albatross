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
    
    var projects = HasMany<Project>()
    
    var largePhotoUrl: Image?
    var photoUrl: Image?
    var smallPhotoUrl: Image?
    var tinyPhotoUrl: Image?
}