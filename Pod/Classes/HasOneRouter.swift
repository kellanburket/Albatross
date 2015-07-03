//
//  HasOneRouter.swift
//  Pods
//
//  Created by Kellan Cummings on 7/2/15.
//
//

import Foundation

public protocol HasOneRouter: Router {
    var passenger: Passenger? { get set }
}