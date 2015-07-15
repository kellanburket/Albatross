//
//  NSDate.swift
//  Pods
//
//  Created by Kellan Cummings on 6/28/15.
//
//

import Foundation

internal extension NSDate {
    internal func format(format: String) -> String {
        var formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
}