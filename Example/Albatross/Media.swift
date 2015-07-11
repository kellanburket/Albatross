//
//  Media.swift
//  Albatross
//
//  Created by Kellan Cummings on 7/11/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation
import Albatross

class Media: Passenger {
    var type: String?

    struct Size {
        var h = Int()
        var w = Int()
        var resize: String?
    }

    var sizes = [
        "thumb": Size(),
        "large": Size(),
        "medium": Size(),
        "small": Size()
    ]
    
    var indices = [Int]()

    var url: Image?
    var mediaUrl: Image?
    var displayUrl: Image?
    var expandedUrl: Image?
    var mediaUrlHttps: Image?

    var idStr: String?

    var entity = BelongsTo<StatusEntity>()
}
