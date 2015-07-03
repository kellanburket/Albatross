//
//  NSData.swift
//  Pods
//
//  Created by Kellan Cummings on 6/14/15.
//
//

import Foundation

extension NSData {
    public func parseJson() -> NSDictionary? {
        var error: NSError?
        if let json = NSJSONSerialization.JSONObjectWithData(self, options: nil, error: &error) as? NSDictionary {
            return json
        } else {
            println("Could not properly parse JSON data: \(error)")
            return nil
        }
    }
}