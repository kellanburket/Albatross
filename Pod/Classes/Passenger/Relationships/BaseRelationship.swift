//
//  Relationship.swift
//  Pods
//
//  Created by Kellan Cummings on 6/30/15.
//
//

import Foundation

internal class BaseRelationship<T: ApiObject>: BaseObject {
    
    var owner: ApiObject?
    
    var endpoint: String {
        return T.className
    }
    
    func setOwner(owner: ApiObject) {
        self.owner = owner
    }
}