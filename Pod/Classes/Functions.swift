//
//  functions.swift
//  Pods
//
//  Created by Kellan Cummings on 6/12/15.
//
//

import Foundation

private let nonceTable: [Character] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];

internal func generateNonce(digits: Int = 7) -> String {
    var nonce: String = ""
    
    for i in 0...digits {
        var index = Int((arc4random() % 62))
        nonce += String([nonceTable[index]])
    }
    
    return nonce
}

internal func getCurrentTimestamp() -> String {
    return String(Int64(NSDate().timeIntervalSince1970))
}

internal func jsonStringify(data: AnyObject) -> NSData? {
    var error: NSError?
    
    if let json = NSJSONSerialization.dataWithJSONObject(
        data,
        options: NSJSONWritingOptions(0),
        error: &error
    ) {
        return json
    } else {
        println("There was an issue converting your object to json")
        return nil
    }
}

internal func Y<T, R>(f: (T -> R) -> (T -> R)) -> (T -> R) {
    return { (t: T) -> R in
        return f(Y(f))(t)
    }
}
