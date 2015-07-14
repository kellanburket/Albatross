//
//  ActiveUrlPath.swift
//  Pods
//
//  Created by Kellan Cummings on 6/14/15.
//
//

import Foundation

internal class ActiveUrlPath: NSObject {
    var parent: ActiveUrlPath?
    var endpoints = [String: Endpoint]()
    var path: String = ""
    
    init(parent: ActiveUrlPath? = nil) {
        self.parent = parent
    }
    
    override var description: String {
        return getDescription()
    }

    func getDescription(_ tabs: Int = 0) -> String {
        return ""
    }

    func getFullUrlString() -> String {
        var path = ""
        
        //println("PATH IN: \(self.path)")
        
        if self.path != "" {
            path = "/" + self.path
        }
        
        if let parent = self.parent {
            var parentPath = parent.getFullUrlString()
            //println("Parent: \(parentPath), Child: \(self.path)")
            return parentPath + path
        } else {
            //println("Parent: nil, Child: \(self.path)")
            return path
        }
        
    }
}