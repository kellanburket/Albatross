//
//  StatusEntity.swift
//  Passenger
//
//  Created by Kellan Cummings on 7/11/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation
import Passenger

class StatusEntity: Entity {
    var userMentions = Entities<UserMention>()
    var urls = Entities<Url>()
    var hashtags = Entities<Hashtag>()
    var media = Entities<Media>()
    var symbols = Entities<Symbol>()
    
    var status = BelongsTo<Status>()
}