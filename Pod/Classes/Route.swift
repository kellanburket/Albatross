//
//  Route.swift
//  Pods
//
//  Created by Kellan Cummings on 6/11/15.
//
//

import Foundation

public class Route {
    var method: HttpMethod?
    var path: String
    
    public init(method: String, path: String) {
        self.method = HttpMethod(rawValue: method)
        self.path = path
    }
}