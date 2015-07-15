//
//  PsuedoRouter.swift
//  Pods
//
//  Created by Kellan Cummings on 7/1/15.
//
//

import Foundation

internal class PseudoRouter: NSObject, Router {
    
    var id = Int()

    private var type: ApiObject.Type
    
    init(type: ApiObject.Type) {
        self.type = type
    }

    internal var parent: ApiObject? {
        return nil
    }

    func construct(args: AnyObject, node: String? = nil) -> AnyObject {
        return type.parse(args, node: node)
    }

    var endpoint: String {
        return type.className
    }
    
    func getOwnershipHierarchy() -> [Router] {
        return [type()]
    }

    internal func describeSelf(_ tabs: Int = 0) -> String {
        return ""
    }
}