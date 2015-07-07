//
//  Router.swift
//  Pods
//
//  Created by Kellan Cummings on 6/30/15.
//
//

import Foundation

public protocol Router {
    var parent: Router? { get }
    var endpoint: String { get }
    func serialize() -> AnyObject?
    func construct(args: [String: AnyObject], node: String?) -> AnyObject
    func getOwnershipHierarchy() -> [Router]
}