//
//  HttpContentType.swift
//  Pods
//
//  Created by Kellan Cummings on 6/12/15.
//
//

import Foundation

public enum HttpContentType: String {
    case Json = "application/json"
    case Html = "text/html"
    case Csv = "text/csv"
    case Plain = "text/plain"
    case FormEncoded = "application/x-www-form-urlencoded"
    
    var description: String {
        return self.rawValue
    }
}
