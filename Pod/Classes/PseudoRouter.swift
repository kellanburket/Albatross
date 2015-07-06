//
//  PsuedoRouter.swift
//  Pods
//
//  Created by Kellan Cummings on 7/1/15.
//
//

import Foundation

class PseudoRouter: NSObject, Router {
    
    var id: Int = 0
    private var type: Passenger.Type
    
    init(type: Passenger.Type) {
        self.type = type
    }

    internal var parent: Router? {
        return nil
    }
    
    func construct(args: [String: AnyObject], node: String? = nil) -> AnyObject {
        return type.parse(args, node: node)
    }

    var endpoint: String {
        return type.className
    }
    
    func getOwnershipHierarchy() -> [Router] {
        return [self]
    }
}