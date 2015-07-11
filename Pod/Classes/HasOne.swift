//
//  HasOne.swift
//  Pods
//
//  Created by Kellan Cummings on 6/30/15.
//
//

import Foundation

public class HasOne<T: Passenger>: BaseRelationship<T>, HasOneRouter {

    override public var kind: String {
        return "hasOne"
    }

    public var model: T? {
        return passenger
    }

    private var passenger: T? {
        didSet {
            if let owner = owner, passenger = passenger {
                var method = owner.asMethodName()

                if let relationship = passenger.belongsTos[method] {
                    relationship.registerPassenger(owner)
                } else {
                    println("'Has One' relationship must register passengers with corresponding 'Belongs To' relationship.")
                }
            } else {
                println("Something went wrong and passenger was not set for 'Has One' relationship.")
            }
        }
    }
    
    public var parent: Passenger? {
        return owner
    }
    
    override public init() {
        super.init()
    }

    public func get() -> Passenger? {
        return passenger
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

    internal func getOwnershipHierarchy() -> [Router] {
        var components = [Router]()
        
        if let passenger = passenger as? Router {
            components << passenger
        }
        
        var router: Router = self
        while let parent = router.parent as? Router {
            components.append(parent)
            router = parent
        }
        
        return components.reverse()
    }

    public func registerPassenger(passenger: Passenger) {
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