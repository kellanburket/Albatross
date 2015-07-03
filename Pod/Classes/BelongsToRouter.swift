//
//  BelongsToRouter.swift
//  Pods
//
//  Created by Kellan Cummings on 7/2/15.
//
//

import Foundation

public protocol BelongsToRouter: Router {
    var passenger: Passenger? { get set }
    func registerPassenger(passenger: Passenger)
}