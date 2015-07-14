//
//  HasMany.swift
//  Pods
//
//  Created by Kellan Cummings on 6/30/15.
//
//

import Foundation

public class HasMany<T: Model>: OneToManyRelationship<T>, SequenceType {
 
    override public init() {
        super.init()
    }
    
    public func list(onComplete: [T]? -> ()) {
         T.list { records in
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
        T.create(params) { record in
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
        
        T.find(passenger.id) { record in
            if let passenger = record as? T {
                self.registerPassenger(passenger)
                onComplete(passenger)
            } else {
                onComplete(nil)
            }
        }
    }

    public func upload(data: [String: NSData], params: [String: AnyObject], onComplete: AnyObject? -> Void) {
        T.upload(data, params: params, onComplete: onComplete)
    }

    public func generate() -> GeneratorOf<T> {
        var index = 0
        return GeneratorOf {
            if index < self.passengers.count {
                return self.passengers[index++]
            }
            
            return nil
        }
    }
}