//
//  HasOne.swift
//  Pods
//
//  Created by Kellan Cummings on 6/30/15.
//
//

import Foundation

public class HasOne<T: Passenger>: Relationship<T>, HasOneRouter {

    public var passenger: Passenger? {
        didSet {
            if let p = passenger as? T, method = owner?.asMethodName() {
                if let relationship = p.BelongsTos[method], owner = owner {
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
    
    public func create(params: [String: AnyObject], onComplete: onPassengerRetrieved) {
        T(params).create { record in
            if let passenger = record as? T {
                self.passenger = passenger
                
                onComplete(self.passenger)
            } else {
                onComplete(nil)
            }
        }
    }
    
    public func find(id: Int, onComplete: onPassengerRetrieved) {
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
    
    public func destroy(onComplete: AnyObject? -> Void) {
        if let passenger = self.passenger {
            passenger.destroy(onComplete)
        }
    }
    
    public func save(onComplete: AnyObject? -> Void) {
        if let passenger = self.passenger {
            passenger.save(onComplete)
        }
    }
    
    public func upload(name: String, data: NSData, params: [String: AnyObject], onComplete: AnyObject? -> Void) {
        if let media = passenger as? Media {
            media.upload(name, data: data, params: params, onComplete: onComplete)
        } else {
            println("Unable to upload.")
            onComplete(nil)
        }
    }
        
    public func serialize() -> AnyObject? {
        return passenger?.serialize()
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