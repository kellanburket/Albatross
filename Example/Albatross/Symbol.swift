//
//  Symbol.swift
//  Albatross
//
//  Created by Kellan Cummings on 7/11/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation
import Albatross

class Symbol: Passenger {
    var text: String?
    var indices = [Int]()

    var entity = BelongsTo<StatusEntity>()
}