//
//  HasManyEntities.swift
//  Pods
//
//  Created by Kellan Cummings on 7/13/15.
//
//

import Foundation

/**
    a OneToManyRelationship wrapper for Entities. Use in place of an array of `Entity`s when setting `ApiObject` properties.
*/
public class Entities<T: Entity>: OneToManyRelationship<T>, SequenceType {
    
    /** 
        Default initializer
    */
    override public init() {
        super.init()
    }

    /**
        Generator used to iterate over `passengers` array
    */
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