//
//  HasOneRouter.swift
//  Pods
//
//  Created by Kellan Cummings on 7/2/15.
//
//

import Foundation

internal protocol HasOneRouter: RelationshipRouter {
    func get() -> Passenger?
}