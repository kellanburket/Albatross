//
//  Dictionary.swift
//  Pods
//
//  Created by Kellan Cummings on 6/11/15.
//
//

import Foundation

internal func +<T, E>(left: [T: E], right: [T: E]) -> [T: E] {
    var d = [T: E]()
    
    for (k, v) in left {
        d[k] = v
    }
    
    for (k, v) in right {
        d[k] = v
    }

    return d
}

internal func +=<T, E>(inout left: [T: E], right: [T: E]) {
    left = left + right
}

internal extension Dictionary {
    
    func flip() -> Dictionary<Key, Value>? {
        if Key.self is Value.Type {
            var out = Dictionary<Key, Value>()
            
            for key in self.keys {
                if let value = self[key] as? Key, key = key as? Value {
                    out[value] = key
                }
            }
            
            return out.count > 0 ? out : nil
        }
        
        return nil
    }

    func formatKeys() -> [String: AnyObject] {
        var output = [String: AnyObject]()
 
        var doRecursion: (AnyObject -> AnyObject) -> (AnyObject -> AnyObject) =  { f in
            return { values in
                if let hash = values as? [String: AnyObject] {
                    return hash.formatKeys()
                } else if let arr = values as? NSArray {
                    var output = [AnyObject]()
                    if arr.count > 0 {
                        for item in arr {
                            output.append(f(item))
                        }
                    }
                    return output
                } else {
                    return values
                }
            }
        }
        
        for (k, v) in self {
            if let key = k as? String, value: AnyObject = v as? AnyObject {
                output[key.toCamelcase()] = Y(doRecursion)(value)
            }
        }
        
        return output
    }
}