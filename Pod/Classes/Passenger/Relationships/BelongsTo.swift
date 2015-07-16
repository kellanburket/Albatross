//
//  BelongsTo.swift
//  Pods
//
//  Created by Kellan Cummings on 6/30/15.
//
//

import Foundation

/**
    If a `Passenger` has a one-to-one or one-to-many relationship with another `Passenger`, the subordinate `Passenger` must have a `BelongsTo<Passenger>` property pointing back to the owning class.

    This class should never be optional or constructed. Preinitialize all BelongsTo properties.
*/
public class BelongsTo<T: ApiObject>: BaseRelationship<T>, BelongsToRouter {
 
    private var passenger: T?
    
    /**
        The parent `Model`
    */
    public var parent: ApiObject? {
        return passenger
    }
    
    /**
        Initializer
    */
    override public init() {
        super.init()
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

    internal func construct(args: AnyObject, node: String? = nil) -> AnyObject {
        var obj: AnyObject = T.parse(args, node: node)
        if let passenger = obj as? ApiObject {
            registerPassenger(passenger)
        }

        return obj
    }

    internal func registerPassenger(passenger: ApiObject) {
        if let passenger = passenger as? T{
            self.passenger = passenger
            self.owner?.parent = passenger
        }
    }
    
    override internal func describeSelf(_ tabs: Int = 0) -> String {
        if let passenger = passenger {
            return passenger.describeSelf(tabs)
        }
        
        return ""
    }
}