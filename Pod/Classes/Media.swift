//
//  PassengerMedia.swift
//  Pods
//
//  Created by Kellan Cummings on 7/3/15.
//
//


import Foundation

public class Media: Passenger {
    internal var url: NSURL?
    private var priority: NSOperationQueuePriority = .Normal

    convenience public init(url: NSURL, id: Int? = nil) {
        self.init(["url": url, "id": id ?? 0])
    }

    required public init(_ properties: [String : AnyObject]) {
        /*
        
        if let uploads = morejson["uploads"] as? NSDictionary {
        if let file0 = uploads["file0"] as? NSDictionary {
        if let imageId = file0["image_id"] as? Int {
        //println("Image ID Returned: \(imageId)")
        Http.post(
        URL,
        params: ["image_id": imageId],
        delegate: delegate,
        action: action
        )
        }
        }
        }
        } else {
        //println("Data is null")
        }
        }
        */
        
        super.init(properties)
    }

    final public func upload(name: String, data: NSData, params: [String: AnyObject], onComplete: AnyObject? -> Void) {
        Api.shared.upload(self, data: [name: data], params: params) { objs in
            if objs?.count > 0 {
                onComplete(objs?[0])
            } else {
                onComplete(nil)
            }
        }
    }
}