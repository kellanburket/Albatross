//
//  Project.swift
//  Albatross
//
//  Created by Kellan Cummings on 6/26/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import UIKit
import Albatross

class Project: Passenger {
    var craft: Craft?
    var pattern: Pattern?
    var name: String?
    var permalink: NSURL?
    var queuePosition: Int = 0
    var rating: String?
    var size: String?

    var user = BelongsToRelationship<User>()
    var comments = HasManyRelationship<Comment>()
    
    var progress: Int = 0 {
        didSet {
            if progress > 100 {
                progress = 100
            } else if progress < 0 {
                progress = 0
            }
        }
    }
    
    var started: NSDate?
    var completed: NSDate?
    var created: NSDate?
    var updated: NSDate?
    var toStart: NSDate?
    
    func reorderPhotos(sortOrder: ImageSet) {
        
    }
    
    func createPhoto() {
        upload {
            
        }
    }
    
    //var yarn: Yarn?
    //var patternSource: PatternSource?
    //var patternAuthor: Author?
    //var madeForUser: RavelryUser?
    //var packs = [Pack]()
    //var needles = [Needle]()
    //var status: Status = .InProgress
    
    /*
    func getYarnName() -> String {
        return yarn?.name ?? ""
    }
    
    func getNeedleDescriptions() -> [String] {
        var arr = [String]()
        for needle in needles {
            arr.append(needle.name)
        }
        return arr
    }
    */
}