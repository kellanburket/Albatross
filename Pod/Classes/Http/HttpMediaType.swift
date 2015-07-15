//
//  HttpContentType.swift
//  Pods
//
//  Created by Kellan Cummings on 6/12/15.
//
//

import Foundation

internal enum HttpMediaType: String {
    case Json = "application/json"
    case Html = "text/html"
    case Csv = "text/csv"
    case Plain = "text/plain"
    case FormEncoded = "application/x-www-form-urlencoded"
    case MultipartFormData = "multipart/form-data"
    
    var description: String {
        return self.rawValue
    }
    
    var fileExtension: String? {
        switch self {
            case Json: return "json"
            case Html: return "html"
            case Csv: return "csv"
            case Plain: return "txt"
            default: return nil
        }
    }
}
