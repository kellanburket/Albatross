//
//  NSDate.swift
//  Pods
//
//  Created by Kellan Cummings on 6/28/15.
//
//

import Foundation

public extension NSDate {
    public func format(format: String) -> String {
        var formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
}