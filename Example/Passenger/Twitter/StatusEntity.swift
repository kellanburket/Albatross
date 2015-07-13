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
    var userMentions = HasMany<UserMention>()
    var urls = HasMany<Url>()
    var hashtags = HasMany<Hashtag>()
    var media = HasMany<Media>()
    var symbols = HasMany<Symbol>()
    
    var status = BelongsTo<Status>()
}