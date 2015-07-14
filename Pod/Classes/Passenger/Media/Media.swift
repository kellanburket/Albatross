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
}