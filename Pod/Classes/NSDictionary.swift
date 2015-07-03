//
//  NSDictionary.swift
//  Pods
//
//  Created by Kellan Cummings on 6/16/15.
//
//

import Foundation

extension NSDictionary {
    
    func formatKeys() -> [String: AnyObject] {
        var output = [String: AnyObject]()

        for (k, v) in self {
            if let key = k as? String {
                output[key.toCamelcase()] = doRecursion(v)
            }
        }
        
        return output
    }
}

func doRecursion(values: AnyObject) -> AnyObject {
    if let hash = values as? NSDictionary {
        return hash.formatKeys()
    } else if let arr = values as? NSArray {

        var output = [AnyObject]()
        if arr.count > 0 {
            for item in arr {
                output.append(doRecursion(item))
            }
        }
        return output
    } else {
        return values
    }
}