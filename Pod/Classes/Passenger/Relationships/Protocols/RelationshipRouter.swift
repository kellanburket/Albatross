//
//  RelationshipRouter.swift
//  Pods
//
//  Created by Kellan Cummings on 7/3/15.
//
//

import Foundation

internal protocol RelationshipRouter: Router {
    var owner: ApiObject? { get set }
    func registerPassenger(passenger: ApiObject)
    func setOwner(passenger: ApiObject)
}