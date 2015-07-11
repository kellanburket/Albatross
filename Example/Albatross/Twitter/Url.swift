//
//  Url.swift
//  Albatross
//
//  Created by Kellan Cummings on 7/9/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation
import Albatross

class Url: Passenger {
    var url: NSURL?
    var expandedUrl: NSURL?
    var displayUrl: NSURL?
    var indices = [Int]()
    
    var entity = BelongsTo<Entity>()
}