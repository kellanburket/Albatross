//
//  PassengerMedia.swift
//  Pods
//
//  Created by Kellan Cummings on 7/3/15.
//
//


import Foundation

public class Media: Passenger {

    public var url: NSURL?
    private var priority: NSOperationQueuePriority = .Normal

    convenience public init(url: NSURL) {
        self.init()
        self.url = url
    }

    required public init(_ properties: Json = Json()) {
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