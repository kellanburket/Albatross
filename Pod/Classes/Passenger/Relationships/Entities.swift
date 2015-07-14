//
//  HasManyEntities.swift
//  Pods
//
//  Created by Kellan Cummings on 7/13/15.
//
//

import Foundation

public class Entities<T: Entity>: OneToManyRelationship<T>, SequenceType {
    
    override public var kind: String {
        return "hasMany"
    }
    
    override public init() {
        super.init()
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