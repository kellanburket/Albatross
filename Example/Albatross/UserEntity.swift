//
//  UserEntity.swift
//  Albatross
//
//  Created by Kellan Cummings on 7/11/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation
import Albatross

class UserEntity: Entity {
    var url = ["urls": HasMany<Url>()]
    var user = BelongsTo<User>()
}