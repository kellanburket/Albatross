//
//  Mention.swift
//  Albatross
//
//  Created by Kellan Cummings on 7/7/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation
import Albatross

class UserMention: Passenger {
    var name: String?
    var idStr: String?
    var indices = [Int]()
    var screenName: String?

    var entity = BelongsTo<StatusEntity>()
}