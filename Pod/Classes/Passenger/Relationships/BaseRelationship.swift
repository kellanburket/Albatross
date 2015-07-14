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

    var endpoint: String {
        return T.className
    }
    
    func setOwner(owner: Passenger) {
        self.owner = owner
    }
}