//
//  Url.swift
//  Passenger
//
//  Created by Kellan Cummings on 7/9/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation
import Passenger

class Url: Passenger.Entity {
    var url: NSURL?
    var expandedUrl: NSURL?
    var displayUrl: NSURL?
    var indices = [Int]()
    
    var userEntity = BelongsTo<UserEntity>()
    var statusEntity = BelongsTo<StatusEntity>()
}