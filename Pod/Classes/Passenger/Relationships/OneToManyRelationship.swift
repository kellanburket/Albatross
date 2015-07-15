//
//  OneToManyRelationship.swift
//  Pods
//
//  Created by Kellan Cummings on 7/13/15.
//
//

import Foundation

internal class OneToManyRelationship<T: ApiObject>: BaseRelationship<T>, HasManyRouter {

    internal var passengers = [T]()
    
    var count: Int {
        return passengers.count
    }

    var parent: ApiObject? {
        return owner
    }

    func first() -> T? {
        if passengers.count > 0 {
            return passengers[0]
        }
        
        return nil
    }
    
    func getOwnershipHierarchy() -> [Router] {
        var components: [Router] = [self]
        var router: Router = self
        
        while let parent = router.parent as? Router {
            components << parent
            router = parent
        }
        
        return components.reverse()
    }
    
    internal func registerPassenger(passenger: ApiObject) {
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
    
    subscript(id: Int) -> T? {
        get {
            return passengers[id]
        }
    }
    
    func construct(args: AnyObject, node: String? = nil) -> AnyObject {
        var obj: AnyObject = T.parse(args, node: node)
        if let passenger = obj as? ApiObject {
            registerPassenger(passenger)
        } else if let passengers = obj as? [ApiObject] {
            for passenger in passengers {
                registerPassenger(passenger)
            }
        }
        
        return obj
    }
    
    override func describeSelf(_ tabs: Int = 0) -> String {
        var output = ""
        
        for passenger in passengers {
            if let passenger = passenger as? Router {
                output += passenger.describeSelf(tabs)
            }
        }
        
        return output
    }
}