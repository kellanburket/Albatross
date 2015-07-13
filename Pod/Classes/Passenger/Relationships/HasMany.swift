//
//  HasMany.swift
//  Pods
//
//  Created by Kellan Cummings on 6/30/15.
//
//

import Foundation

public class HasMany<T: Passenger>: BaseRelationship<T>, HasManyRouter, SequenceType {
 
    private var passengers = [T]()
    
    public var count: Int {
        return passengers.count
    }

    override public init() {
        super.init()
    }

    override public var kind: String {
        return "hasMany"
    }

    public var parent: Passenger? {
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
        Api.shared.create(self, params: params) { record in
            if let passenger = record as? T {
                self.registerPassenger(passenger)
                onComplete(passenger)
            } else {
                onComplete(nil)
            }
        }
    }
    
    public func first() -> T? {
        if passengers.count > 0 {
            return passengers[0]
        }
        
        return nil
    }
    
    public func all() -> [Passenger] {
        return passengers
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

    public func upload(data: [String: NSData], params: [String: AnyObject], onComplete: AnyObject? -> Void) {
        //let router = PseudoRouter(type: T.self)
        Api.shared.upload(self, data: data, params: params) { objs in
            println("Upload Completed: \(objs)")
        }
    }

    internal func getOwnershipHierarchy() -> [Router] {
        var components = [Router]()
        var router: Router = self
        
        while let parent = router.parent as? Router {
            components.append(parent)
            router = parent
        }
        
        return components.reverse()
    }
    
    internal func registerPassenger(passenger: Passenger) {
        if let passenger = passenger as? T, method = owner?.asMethodName() {
            
            if let relationship = passenger.belongsTos[method], owner = owner {
                relationship.registerPassenger(owner)
                //println("Registering \(passenger.id)")
                passengers << passenger
            } else {
                println("('\(passenger.dynamicType.className)' missing belongsTo<\(method)> relationship")
            }
            
        } else {
            println("Could not register passenger of type '\(passenger.endpoint)' : \(T.className) owned by \(owner?.asMethodName()).")
        }
    }

    public subscript(id: Int) -> T? {
        get {
            return passengers[id]
        }
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
    
    override internal func describeSelf(_ tabs: Int = 0) -> String {
        var output = ""
        
        for passenger in passengers {
            if let passenger = passenger as? Router {
                output += passenger.describeSelf(tabs)
            }
        }
        
        return output
    }


}