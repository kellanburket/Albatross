//
//  HasManyRouter.swift
//  Pods
//
//  Created by Kellan Cummings on 7/2/15.
//
//

import Foundation

public protocol HasManyRouter: Router {
    var passengers: [Passenger] { get set }
}