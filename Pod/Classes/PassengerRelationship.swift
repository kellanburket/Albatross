//
//  PassengerRelationship.swift
//  Pods
//
//  Created by Kellan Cummings on 6/30/15.
//
//

import Foundation
import Wildcard

public class PassengerRelationship<T: Passenger>: NSObject {

    public var owner: Passenger?

    public var id: Int {
        return owner?.id ?? 0
    }

    internal func serialize() -> [String: AnyObject] {
        return [String: AnyObject]()
    }
    
    internal func getClassName() -> String {
        return "\(T.self)".split(".").last ?? ""
    }

    public func getType() -> Passenger.Type {
        return T.self
    }

    public func asEndpointPath() -> String {
        return getType().className
    }
}