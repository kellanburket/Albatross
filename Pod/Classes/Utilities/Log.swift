//
//  Log.swift
//  Pods
//
//  Created by Kellan Cummings on 7/9/15.
//
//

import Foundation

public class Log {
    class public func d(str: String) {
        if let dir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .AllDomainsMask, true) as? [String] {
            if File.mkdir("\(dir[0])/logs") {
                File.write(str, path: "\(dir[0])/logs/dril.json")
            }
        } else {
            println("Unable to write to logfile")
        }
    }
}
