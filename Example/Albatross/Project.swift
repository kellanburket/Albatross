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

    var user = BelongsTo<User>()
    var comments = HasMany<Comment>()
    
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
    
    func reorderPhotos(sortOrder: [Int], onComplete: onPassengerOperationSuccess) {
        
    }
    
    func createPhoto(images: [String: UIImage], onComplete: AnyObject? -> Void) {
        let upload = Resource("Upload")
        
        upload.create { data in
            if let json = data as? Json, token = json["upload_token"] as? String {
                
                //println("About to Upload Image")
                var data = [String: NSData]()

                for (name, image) in images {
                    data[name] = image.toJpgData()
                }
                
                var params: [String: AnyObject] = [
                    "upload_token": token,
                    "access_key": Api.shared.key
                ]
                
                upload.resource("Image").upload(data, params: params, onComplete: { raw in
                    if let medias = raw as? Json {
                        for (name, file) in medias {
                            if let media = file as? Json {
                                self.doAction("create_photo", params: media, onComplete: onComplete)
                            }
                        }
                    }
                    //onComplete(medias)
                })
            } else {
                println("Upload Token does not exist. \(data)")
                onComplete(nil)
            }
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