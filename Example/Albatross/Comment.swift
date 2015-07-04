//
//  Comment.swift
//  Albatross
//
//  Created by Kellan Cummings on 7/4/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation
import Albatross

class Comment: Passenger {

    var createdAt: NSDate?
    var commentHtml: String?
    var higlightedProject = BelongsToRelationship<Project>()
    
}