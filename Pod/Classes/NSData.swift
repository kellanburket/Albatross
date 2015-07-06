//
//  NSData.swift
//  Pods
//
//  Created by Kellan Cummings on 6/14/15.
//
//

import Foundation

extension NSData {
    public func parseJson() -> [String: AnyObject]? {
        var error: NSError?
        if let json = NSJSONSerialization.JSONObjectWithData(self, options: nil, error: &error) as? [String: AnyObject] {
            return json
        } else {
            println("Could not properly parse JSON data: \(error)")
            return nil
        }
    }

    func toString(encoding: UInt = NSUTF8StringEncoding) -> String? {
        return NSString(data: self, encoding: encoding) as? String
    }
}