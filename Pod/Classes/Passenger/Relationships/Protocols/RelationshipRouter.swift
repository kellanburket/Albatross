//
//  RelationshipRouter.swift
//  Pods
//
//  Created by Kellan Cummings on 7/3/15.
//
//

import Foundation

internal protocol RelationshipRouter: Router {
    var owner: Passenger? { get set }
    var kind: String { get }
    func registerPassenger(passenger: Passenger)
    func setOwner(passenger: Passenger)
}