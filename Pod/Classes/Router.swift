//
//  Router.swift
//  Pods
//
//  Created by Kellan Cummings on 6/30/15.
//
//

import Foundation

public protocol Router {
    var id: Int { get }
    var parent: Router? { get }
    func getType() -> Passenger.Type
    func setPathVariables(var path: String) -> String
}