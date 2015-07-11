//
//  BelongsTo.swift
//  Pods
//
//  Created by Kellan Cummings on 6/30/15.
//
//

import Foundation

public class BelongsTo<T: Passenger>: BaseRelationship<T>, BelongsToRouter {
 
    private var passenger: T?

    public var model: T? {
        return passenger
    }

    override public var kind: String {
        return "belongsTo"
    }
    
    public var parent: Passenger? {
        return passenger
    }
    
    override public init() {
        super.init()
    }
    
    public func get() -> Passenger? {
        return passenger
    }

    internal func getOwnershipHierarchy() -> [Router] {
        var components = [Router]()
        var router: Router? = self

        if let passenger = passenger as? Router {
            components << passenger
        }

        while let parent = router?.parent as? Router {
            components << parent
            router = router?.parent
        }
        
        return components.reverse()
    }

    internal func registerPassenger(passenger: Passenger) {
        if let passenger = passenger as? T{
            self.passenger = passenger
        }
    }
    
    override internal func describeSelf(_ tabs: Int = 0) -> String {
        if let passenger = passenger {
            return passenger.describeSelf(tabs)
        }
        
        return ""
    }
}