//
//  Router.swift
//  Pods
//
//  Created by Kellan Cummings on 6/30/15.
//
//

import Foundation

internal protocol Router {
    var parent: Passenger? { get }
    var endpoint: String { get }
    func construct(args: AnyObject, node: String?) -> AnyObject
    func getOwnershipHierarchy() -> [Router]
    func describeSelf(tabs: Int) -> String
}