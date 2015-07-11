//
//  Array.swift
//  Pods
//
//  Created by Kellan Cummings on 6/11/15.
//
//

import Foundation
import Wildcard

func +=<T>(left: [T], right: [T]) -> [T] {
    return left + right
}

func <<<T>(inout left: [T], right: T) {
    left.append(right)
}

extension Array {
    mutating func shift() -> T? {
        return self.count > 0 ? self.removeAtIndex(0) : nil
    }
    
    mutating func pop() -> T? {
        return self.count > 0 ? self.removeLast() : nil
    }
    
    func join(delimiter: String) -> String {
        var joined = ""
        for str in self {
            joined += "\(str)\(delimiter)"
        }
        
        return joined.trim(delimiter)
    }
}