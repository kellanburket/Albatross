//
//  BelongsToRelationship.swift
//  Pods
//
//  Created by Kellan Cummings on 6/30/15.
//
//

import Foundation

public class BelongsToRelationship<T: Passenger>: PassengerRelationship<T>, BelongsToRouter {
 
    public var passenger: Passenger?
    
    override public init(_ owner: Passenger) {
        super.init(owner)
    }
    
    public func registerPassenger(passenger: Passenger) {
        self.passenger = passenger
    }

    override public var parent: Router? {
        return passenger
    }
}