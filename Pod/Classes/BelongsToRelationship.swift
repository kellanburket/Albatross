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
    
    override public init() {
        super.init()
    }

    public func getOwnershipHierarchy() -> [Router] {
        var components: [Router] = [self]
        var router: Router? = self
        
        while let parent = router?.parent {
            println("\tparent: \(parent)")
            components.append(parent)
            router = router?.parent
        }
        
        return components.reverse()
    }

    public func registerPassenger(passenger: Passenger) {
        self.passenger = passenger
    }

    public var parent: Router? {
        return passenger
    }
}