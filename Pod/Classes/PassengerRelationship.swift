//
//  PassengerRelationship.swift
//  Pods
//
//  Created by Kellan Cummings on 6/30/15.
//
//

import Foundation
import Wildcard

public class PassengerRelationship<T: Passenger>: Router {

    internal var owner: Passenger

    public var id: Int {
        return owner.id
    }
    
    internal init(_ owner: Passenger) {
        self.owner = owner
    }

    internal func serialize() -> [String: AnyObject] {
        return [String: AnyObject]()
    }
    
    internal func getClassName() -> String {
        return "\(T.self)".split(".").last ?? ""
    }

    public func getType() -> Passenger.Type {
        return T.self
    }

    public func setPathVariables(var path: String) -> String {
        return path
    }

    public var parent: Router? {
        return owner.parent
    }
}

/* Just in Case ...

var parts = match.split(".")
//println("\tparts: \(parts)")
//println("\tparams: \(params)")
if let name = parts.shift(), let obj: AnyObject = params[name] {
if let dictionary = obj as? [String: AnyObject] {
if let part = parts.shift() {
if let value: AnyObject = dictionary[part] {
str = str.gsub(":\(match)", "\(value)")
}
}
} else {
let reflection = reflect(obj)
//println("\t\treflection \(reflection)")
if let part = parts.shift() {
//println("\t\t\tpart: \(part)")
for i in 0..<reflection.count {
let (fieldName, fieldMirror) = reflection[i]
if fieldName == part {
//println("\t\t\t\t\(fieldName) == \(part)")
if fieldMirror.disposition == .Optional && fieldMirror.count > 0 && fieldMirror[0].0 == "Some" {
let value = fieldMirror[0].1.value
str = str.gsub(":\(match)", "\(value)")
break
} else if let value: AnyObject = fieldMirror.value as? AnyObject {
//println("\t\t\t\t\tSubstitution ':\(match)' => '\(value)'")
str = str.gsub(":\(match)", "\(value)")
break
}
} else {
//println("\t\t\t\t\(fieldName) != \(part)")
}
}
}
}
}
*/