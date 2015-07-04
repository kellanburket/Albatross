//
//  HasOneRelationship.swift
//  Pods
//
//  Created by Kellan Cummings on 6/30/15.
//
//

import Foundation

public class HasOneRelationship<T: Passenger>: PassengerRelationship<T>, HasOneRouter {

    public var passenger: Passenger? {
        didSet {
            if let p = passenger as? T, method = owner?.asMethodName() {
                if let relationship = p.belongsToRelationships[method], owner = owner {
                    relationship.registerPassenger(owner)
                } else {
                    fatalError("'Has One' relationship must register passengers with corresponding 'Belongs To' relationship.")
                }
            } else {
                fatalError("Something went wrong and passenger was not set for 'Has One' relationship.")
            }
        }
    }
    
    public var parent: Router? {
        return owner
    }

    override public var id: Int {
        return passenger?.id ?? 0
    }
    
    override public init() {
        super.init()
    }
    
    public func create(params: [String: AnyObject], onComplete: Passenger? -> Void) {
        T(params).create { record in
            if let passenger = record as? T {
                self.passenger = passenger
                
                onComplete(self.passenger)
            } else {
                onComplete(nil)
            }
        }
    }
    
    public func find(id: Int, onComplete: Passenger? -> Void) {
        passenger = T(["id": id])

        Api.shared.find(self) { record in
            if let passenger = record as? T {
                self.passenger = passenger
                onComplete(self.passenger)
            } else {
                onComplete(nil)
            }
            
        }
    }
    
    public func destroy(onComplete: Bool -> Void) {
        if let passenger = self.passenger {
            passenger.destroy { success in
                if success {
                    self.passenger = nil
                }
                
                onComplete(success)
            }
        }
    }
    
    public func save(onComplete: Bool -> Void) {
        if let passenger = self.passenger {
            passenger.save(onComplete)
        }
    }
        
    override public func serialize() -> [String: AnyObject] {
        
        if let passenger = self.passenger {
            return passenger.serialize()
        }
        
        return [String: AnyObject]()
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

    public func registerPassenger(passenger: Passenger) {
        self.passenger = passenger
    }

}