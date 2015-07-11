//
//  Relationship.swift
//  Pods
//
//  Created by Kellan Cummings on 6/30/15.
//
//

import Foundation
import Wildcard

internal class BaseRelationship<T: Passenger>: BaseObject {

    var owner: Passenger?
        
    var kind: String {
        return String()
    }
    
    func construct(args: AnyObject, node: String? = nil) -> AnyObject {
        return T.parse(args, node: node)
    }

    var endpoint: String {
        return T.className
    }
    
    func setOwner(owner: Passenger) {
        self.owner = owner
    }
}