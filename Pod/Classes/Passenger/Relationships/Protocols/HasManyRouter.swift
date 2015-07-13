//
//  HasManyRouter.swift
//  Pods
//
//  Created by Kellan Cummings on 7/2/15.
//
//

import Foundation

internal protocol HasManyRouter: RelationshipRouter {
    func all() -> [Passenger]
}