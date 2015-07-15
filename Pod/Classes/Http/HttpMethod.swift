//
//  HttpMethod.swift
//  Pods
//
//  Created by Kellan Cummings on 6/12/15.
//
//

import Foundation

internal enum HttpMethod: String {
    case Post = "POST"
    case Put = "PUT"
    case Delete = "DELETE"
    case Get = "GET"
    
    var description: String {
        return self.rawValue
    }
    
    static func match(str: String) -> HttpMethod? {
        switch str.lowercaseString {
            case "post", "create":
                return Post
            case "get", "list", "search", "find", "fetch":
                return Get
            case "put", "update", "save":
                return Put
            case "delete", "destroy":
                return Delete
            default:
                return nil
        }
    }
}
