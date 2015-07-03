//
//  PsuedoRouter.swift
//  Pods
//
//  Created by Kellan Cummings on 7/1/15.
//
//

import Foundation

class PseudoRouter: Router {
    
    var id: Int = 0
    private var type: Passenger.Type
    private var components: [String]
    
    init(type: Passenger.Type, components: [String]) {
        self.type = type
        self.components = components
    }

    internal var parent: Router? {
        return nil
    }
    
    func getType() -> Passenger.Type {
        return type
    }
    
    func setPathVariables(var path: String) -> String {
        println("Path: \(path)")
        if let matches = path.scan("(?<=:)[\\w_\\.\\d]+(?=\\/|$)") {
            println("Matches: \(matches)")
            for arrMatch in matches {
                for match in arrMatch {
                    println("Match \(match)")
                    /*
                    if let mirror = mirrors[match], value: AnyObject = getMirrorValue(mirror) {
                        println("Setting Match \(value)")
                        path = path.gsub(":\(match)", "\(value)")
                    }
                    */
                }
            }
        }
        
        return path
    }

}