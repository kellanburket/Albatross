//
//  Hashtag.swift
//  Albatross
//
//  Created by Kellan Cummings on 7/11/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation
import Albatross

class Hashtag: Passenger {
    var indices = [Int]()
    var text = String()
    
    var entity = BelongsTo<StatusEntity>()
}
