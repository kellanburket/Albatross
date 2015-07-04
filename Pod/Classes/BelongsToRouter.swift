//
//  BelongsToRouter.swift
//  Pods
//
//  Created by Kellan Cummings on 7/2/15.
//
//

import Foundation

public protocol BelongsToRouter: RelationshipRouter {
    var passenger: Passenger? { get set }
}