//
//  HasManyRelationship.swift
//  Pods
//
//  Created by Kellan Cummings on 6/30/15.
//
//

import Foundation

public class HasManyRelationship<T: Passenger>: PassengerRelationship<T>, HasManyRouter {
 
    public var passengers = [Int: Passenger]()    
    
    override public init() {
        super.init()
    }

    override internal func getClassName() -> String {
        return ("\(T.self)".split(".").last ?? "").pluralize()
    }
    
    public var parent: Router? {
        return owner
    }

    public func list(onComplete: [T]? -> ()) {
        Api.shared.list(self) { records in
            if let passengers = records as? [T] {
                for passenger in passengers {
                    self.registerPassenger(passenger)
                }
                onComplete(passengers)
            } else {
                onComplete(nil)
            }
        }
    }
    
    public func create(params: [String: AnyObject], onComplete: T? -> Void) {
        Api.shared.create(self, data: params) { record in
            if let passenger = record as? T {
                self.registerPassenger(passenger)
                onComplete(passenger)
            } else {
                onComplete(nil)
            }
        }
    }
    
    public func find(id: Int, onComplete: T? -> Void) {
        let passenger = T(["id": id])
        registerPassenger(passenger)
        
        if let router = passenger as? Router {
            Api.shared.find(router) { record in
                if let passenger = record as? T {
                    self.registerPassenger(passenger)
                    onComplete(passenger)
                } else {
                    onComplete(nil)
                }
            }
        } else {
            fatalError("'\(T.self)' is not compatible with `Router` protocol.")
        }
    }

    public func getOwnershipHierarchy() -> [Router] {
        var components: [Router] = [self]
        var router: Router = self
        
        while let parent = router.parent {
            components.append(parent)
            router = parent
        }
        
        return components.reverse()
    }

    public override func serialize() -> [String: AnyObject] {
        var serial = [String: AnyObject]()
        for (id, passenger) in passengers {
            serial["\(id)"] = passenger.serialize()
        }
        return serial
    }
        
    public func registerPassenger(passenger: Passenger) {
        if let passenger = passenger as? T, method = owner?.asMethodName() {
 
            if let relationship = passenger.belongsToRelationships[method], owner = owner {
                relationship.registerPassenger(owner)
                passengers[passenger.id] = passenger
            } else {
                fatalError("'Has Many' relationship ('\(owner?.dynamicType.className)' has many '\(passenger.asMethodName().pluralize())') must register '\(passenger.dynamicType.className)' with corresponding 'Belongs To' ('\(passenger.dynamicType.className)' belongs to '\(method)') relationship.")
            }
        } else {
            fatalError("Cannot register passenger of type '\(passenger.self)'.")
        }
    }

    public subscript(id: Int) -> Passenger? {
        get {
            return passengers[id]
        }
    }
}