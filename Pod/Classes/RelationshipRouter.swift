//
//  RelationshipRouter.swift
//  Pods
//
//  Created by Kellan Cummings on 7/3/15.
//
//

import Foundation

public protocol RelationshipRouter: Router {
    var owner: Passenger? { get set }
    func registerPassenger(passenger: Passenger)
}