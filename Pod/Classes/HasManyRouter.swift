//
//  HasManyRouter.swift
//  Pods
//
//  Created by Kellan Cummings on 7/2/15.
//
//

import Foundation

public protocol HasManyRouter: RelationshipRouter {
    var passengers: [Int: Passenger] { get set }
}