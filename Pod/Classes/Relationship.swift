//
//  Relationship.swift
//  Pods
//
//  Created by Kellan Cummings on 6/30/15.
//
//

import Foundation
import Wildcard

public class Relationship<T: Passenger>: NSObject {

    public var owner: Passenger?

    public var id: Int {
        return owner?.id ?? 0
    }

    internal func serialize() -> [String: AnyObject] {
        return [String: AnyObject]()
    }
    
    public func construct(args: [String: AnyObject], node: String? = nil) -> AnyObject {
        return T.parse(args, node: node)
    }

    public var endpoint: String {
        return T.className
    }
}