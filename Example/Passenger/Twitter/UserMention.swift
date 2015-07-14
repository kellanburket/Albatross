//
//  Mention.swift
//  Passenger
//
//  Created by Kellan Cummings on 7/7/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation
import Passenger

class UserMention: Entity {
    var name: String?
    var idStr: String?
    var indices = [Int]()
    var screenName: String?

    var entity = BelongsTo<StatusEntity>()
}