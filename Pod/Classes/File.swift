//
//  File.swift
//  Pods
//
//  Created by Kellan Cummings on 7/9/15.
//
//

import Foundation

class File {
    
    class func mkdir(path: String) -> Bool {
        if !NSFileManager.defaultManager().fileExistsAtPath(path) {
            var error: NSError?
            
            NSFileManager.defaultManager().createDirectoryAtPath(
                path,
                withIntermediateDirectories: true,
                attributes: nil,
                error: &error
            )

            if let error = error {
                println("Error creating directory @ '\(path)'")
                println(error)
                return false
            } else {
                //println("Successfully created directory @ '\(path)'")
                return true
            }
        } else {
            return true
        }
    }
    
    class func read() {
        
    }
    
    class func write(content: String, path: String) -> Bool {
        var error: NSError?
        
        content.writeToFile(
            path,
            atomically: false,
            encoding: NSUTF8StringEncoding,
            error: &error
        )
        
        if let error = error {
            println("Error writing to file @ '\(path)'")
            println(error)
            return false
        } else {
            //println("Successfully wrote to file @ '\(path)'")
            return true
        }
    }
    
}