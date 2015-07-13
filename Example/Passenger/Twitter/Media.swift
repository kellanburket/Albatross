//
//  Media.swift
//  Passenger
//
//  Created by Kellan Cummings on 7/11/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation
import Passenger

class Media: Passenger.Entity {
    var type: String?

    var sizes = [
        "thumb": ImageSize(),
        "large": ImageSize(),
        "medium": ImageSize(),
        "small": ImageSize()
    ]
    
    var indices = [Int]()

    var mediaUrl = Image()
    var displayUrl = Image()
    var expandedUrl = Image()
    var mediaUrlHttps = Image()

    var idStr: String?

    var entity = BelongsTo<StatusEntity>()
}
