//
//  Endpoint.swift
//  Pods
//
//  Created by Kellan Cummings on 6/11/15.
//
//

import Foundation

public class Endpoint {
    
    var type: String?
    var routes = [Route]()
    var endpoints = [Endpoint]()
    
    public init(type: String, values: NSDictionary) {
        self.type = type
        for (key, value) in values {
            if let string = value as? String {
                self.routes.append(Route(method: key as! String, path: string))
            } else if let hash = value as? NSDictionary {
                self.endpoints.append(Endpoint(type: key as! String, values: hash))
            }
        }
    }
}