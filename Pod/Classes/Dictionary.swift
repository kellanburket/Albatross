//
//  Dictionary.swift
//  Pods
//
//  Created by Kellan Cummings on 6/11/15.
//
//

import Foundation

func +<T, E>(left: [T: E], right: [T: E]) -> [T: E] {
    var d = [T: E]()
    for (k, v) in left {
        d[k] = v
    }
    
    for (k, v) in right {
        d[k] = v
    }
    
    return d
}

func +=<T, E>(left: [T: E], right: [T: E]) -> [T: E] {
    return left + right
}