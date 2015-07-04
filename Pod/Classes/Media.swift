//
//  PassengerMedia.swift
//  Pods
//
//  Created by Kellan Cummings on 7/3/15.
//
//

import Foundation

public class Media: NSObject {
    public var id: Int?
    internal var url: NSURL
    private var priority: NSOperationQueuePriority = .Normal

    public init(url: NSURL, id: Int? = nil) {
        self.url = url
        self.id = id
    }
}