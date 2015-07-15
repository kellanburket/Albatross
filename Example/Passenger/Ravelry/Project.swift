//
//  Project.swift
//  Passenger
//
//  Created by Kellan Cummings on 6/26/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import UIKit
import Passenger

class Project: BaseRavelryModel {
    var craft: Craft?
    var pattern: Pattern?
    var name: String?
    var permalink: NSURL?
    var queuePosition: Int = 0
    var rating: String?
    var size: String?

    var user = BelongsTo<RavelryUser>()
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
    
    func reorderPhotos(sortOrder: [Int], onComplete: Bool -> Void) {
        
    }
    
    func createPhoto(images: [String: UIImage], onComplete: AnyObject? -> Void) {
        let upload = BaseRavelryResource("Upload")

        upload.create { data in
            if let json = data as? [String: AnyObject], token = json["upload_token"] as? String {
                
                //println("About to Upload Image")
                var data = [String: NSData]()

                for (name, image) in images {
                    data[name] = Image.toJpg(image)
                }
                
                var params: [String: AnyObject] = [
                    "upload_token": token,
                    "access_key": Api.shared("ravelry").key
                ]
                
                upload.resource("Image").upload(data, params: params, onComplete: { raw in
                    if let medias = raw as? [String: AnyObject] {
                        for (name, file) in medias {
                            if let media = file as? [String: AnyObject] {
                                self.doAction("create_photo", params: media, onComplete: onComplete)
                            } else {
                                onComplete(nil)
                            }
                        }
                    } else {
                        onComplete(nil)
                    }
                })
            } else {
                println("Upload Token does not exist. \(data)")
                onComplete(nil)
            }
        }
    }
}