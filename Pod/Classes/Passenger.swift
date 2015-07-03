//
//  Passenger.swift
//  Pods
//
//  Created by Kellan Cummings on 6/10/15.
//
//

import Foundation
import Reflektor

/**
    When extending the Passenger class, please note that all so-called primitive types with the exception of String (e.g., Int, Float, Double, Bool) must be declared as non-optionals or an `NSUnknownKeyException` will be thrown when attempting to set values. We hope that future releases of Swift will expand the reflection API and allow for more robust key-value coding.

    Currently the following types are supported:
    
    * Int, UInt, Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64
    * Bool
    * Float, Double
    * String, Optional<String>
    * Character
    * NSDate, Optional<NSDate>, PassengerDate, PassengerDatetime, PassengerTime
    * NSURL, Optional<NSURL>
    * Passenger, Optional<Passenger>

*/

public class Passenger: NSObject, Router {

    public var id: Int = 0

    class var className: String {
        return "\(self.self)".split(".").last ?? ""
    }
    
    internal func asMethodName() -> String {
        return "\(self.self)".split(".").last?.decapitalize ?? ""
    }

    public lazy var hasManyRelationships: [String: HasManyRouter] = {
        return self.getRelationships(HasManyRouter.self)
    }()

    public lazy var hasOneRelationships: [String: HasOneRouter] = {
        return self.getRelationships(HasOneRouter.self)
    }()
    
    public lazy var belongsToRelationships: [String: BelongsToRouter] = {
        return self.getRelationships(BelongsToRouter.self)
    }()
    
    internal lazy var mirrors: [String: MirrorType] = {
        var mirrors = [String: MirrorType]()
        let reflection = reflect(self)
  
        var writeMirrors: (MirrorType -> Void) -> (MirrorType -> Void) = { f in
            return { reflection in
                for i in 0..<reflection.count {
                    let (name, mirror) = reflection[i]
                    if name == "super" {
                        f(mirror)
                    } else {
                        mirrors[name] = mirror
                    }
                }
            }
        }

        Y(writeMirrors)(reflection)
        
        return mirrors
    }()
    
    private func getRelationships<T>(type: T.Type) -> [String: T] {
        var relationships = [String: T]()
        for (name, mirror) in self.mirrors {
            if mirror.valueType is T {
                if let value = getMirrorValue(mirror) as? T {
                    relationships[name] = value
                }
            }
        }
        
        return relationships
    }
    
    private class func getRouter(params: [String: AnyObject] = [String: AnyObject]()) -> Router {
        return PseudoRouter(type: self, components: [self.className])
    }
    
    required public init(_ properties: [String: AnyObject]) {
        super.init()
        unserialize(properties)
    }

    final public func save(onComplete: (Bool) -> ()) {
        Api.shared.save(self, data: serialize(), onComplete: onComplete)
    }

    final public class func find(id: Int, onComplete: Passenger? -> Void) {
        Api.shared.find(self(["id": id])) { obj in
            if let record = obj as? Passenger {
                onComplete(record)
            } else {
                onComplete(nil)
            }
        }
    }

    final public func create(onComplete: Passenger? -> Void) {
        Api.shared.create(self, data: serialize()) { obj in
            if let record = obj as? Passenger {
                self.id = record.id
                onComplete(self)
            } else {
                onComplete(nil)
            }
        }
    }

    final public func destroy(onComplete: Bool -> Void) {
        Api.shared.destroy(self, onComplete: onComplete)
    }

    
    final public class func list(onComplete: [Passenger]? -> Void) {
        Api.shared.list(self.getRouter()) { records in
            if let arr = records as? [Passenger] {
                onComplete(arr)
            } else {
                fatalError("\(records)")
                //onComplete(nil)
            }
        }
    }

    final public class func search(params: [String: AnyObject], onComplete: [Passenger]? -> Void) {
        Api.shared.search(self.getRouter(), params: params) { records in
            if let arr = records as? [Passenger] {
                onComplete(arr)
            } else {
                fatalError("\(records)")
                //onComplete(nil)
            }
        }
    }
    
    private func unserialize(var data: [String:AnyObject]) {
        if let d = data[self.dynamicType.className.lowercaseString] as? [String:AnyObject]  {
            data = d
        }
        
        let copy = reflect(self)
        for index in 0 ..< copy.count {
            let (fieldName, fieldMirror) = copy[index]
            setMirrorValue(fieldName, mirror: fieldMirror, data: data)
        }
    }
    
    public func serialize() -> [String: AnyObject] {
        var serial = [String: AnyObject]()
        
        for (fieldName, fieldMirror) in mirrors {
            if fieldName == "super" && fieldMirror.count > 0 {
                for i in 1..<fieldMirror.count {
                    var (parentFieldName, parentFieldMirror) = fieldMirror[i]
                    if let parentFieldValue: AnyObject = getMirrorValue(parentFieldMirror) {
                        serial[parentFieldName] = parentFieldValue
                    }
                }
            } else {
                if let value: AnyObject = getMirrorValue(fieldMirror) {
                    serial[fieldName] = value
                }
            }
        }
        
        //println(serial)
        return serial
    }

    private func setMirrorValue(name: String, mirror: MirrorType, data: [String:AnyObject]) {
        let type = mirror.valueType
        
        //println("Setting \(name) : \(type)")
        //println("Fetching \(name) : \(data[name])")
        
        if name == "super" {
            if mirror.count > 0 {
                for i in 0..<mirror.count {
                    let (fieldName, fieldMirror) = mirror[i]
                    setMirrorValue(fieldName, mirror: fieldMirror, data: data)
                }
            }
        }
        
        if let value = data[name] as? Int {
            //println("Setting Mirror (Int) \(name) : \(value)")
            if type is Int.Type || type is UInt.Type || type is UInt8.Type || type is UInt16.Type || type is UInt32.Type || type is UInt64.Type || type is Int8.Type || type is Int16.Type || type is Int32.Type || type is Int64.Type {
                //println("Setting (Int) \(name) : \(value)")
                self.setValue(value, forKey: name)
            } else if type is Bool.Type {
                //println("Setting (Bool) \(name) : \(value)")
                self.setValue(value == 1, forKey: name)
            }
        } else if let value = data[name] as? String {
            if type is String.Type || type is Optional<String>.Type {
                //println("Setting (String) \(name) : \(value)")
                self.setValue(value, forKey: name)
            } else if type is Character.Type {
                self.setValue(value, forKey: name)
            } else if type is NSDate.Type || type is Optional<NSDate>.Type {
                if let date = value.toDate() {
                    //println("Setting NSDate \(name) : \(value)")
                    self.setValue(date, forKey: name)
                }
            } else if type is NSURL.Type || type is Optional<NSURL>.Type {
                if let url = value.toUrl() {
                    //println("Setting NSURL \(name) : \(value)")
                    self.setValue(url, forKey: name)
                }
            } else if type is NSAttributedString.Type || type is Optional<NSAttributedString>.Type {
                //self.setValue(value, forKey: name)
            }
        } else if let value = data[name] as? Double {
            if type is Float.Type {
                //println("Setting (Float) \(name) : \(value)")
                self.setValue(value, forKey: name)
            } else if type is Double.Type {
                //println("Setting (Double) \(name) : \(value)")
                self.setValue(value, forKey: name)
            }
        } else if let values = data[name] as? NSDictionary {
            let clzName = "\(Api.shared.namespace).\(name.capitalizedString)"
            //println("Setting (\(clzName))")
            if let obj = ClassReflektor.create(clzName, initializer: "init:", argument: values) as? Passenger {
                self.setValue(obj, forKey: name)
            } else {
                //For Dictionaries
            }
        } else if let value = data[name] as? Passenger {
            //println("Setting \(name) : \(value)")
            self.setValue(value, forKey: name)
        } else if let values = data[name] as? [AnyObject] {
            println("Setting (Arr) \(name)")
            for value in values {
                println("\t\(value)")
                //setMirrorValue(name, mirror: mirror, data: data)
            }
        }
    }

    private func getMirrorValue(fieldMirror: MirrorType) -> AnyObject? {
        if let value = fieldMirror.value as? Passenger {
            //println("setting AnyObject \(fieldName): \(value)")
            return value.serialize()
        } else if let value: AnyObject = fieldMirror.value as? AnyObject {
            //println("setting AnyObject \(fieldName): \(value)")
            return value
        } else if fieldMirror.disposition == .Optional && fieldMirror.count > 0 {
            switch fieldMirror.count {
            case 1:
                //println("Setting Optional: \(fieldName)")
                if fieldMirror[0].0 == "Some" {
                    if let value = fieldMirror[0].1.value as? Passenger {
                        return value.serialize()
                    } else if let value = fieldMirror[0].1.value as? NSDate {
                        return "\(value)".gsub("(\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}).*", "$1")
                        // println("Setting Value: \(fieldName) \(serial[fieldName]!)")
                    } else if let value: AnyObject = fieldMirror[0].1.value as? AnyObject {
                        return value
                    }
                }
            default:
                var arr = [AnyObject]()
                //for obj in fieldMirror {
                //if obj.0 == "Some" {
                
                //serial[fieldName] = fieldMirror.value
                //}
            }
            //println(fieldMirror[0].1)
        } else {
            //println("Not Setting \(fieldName)")
        }
        
        return nil
    }

    class func parse(raw: NSDictionary) -> AnyObject {
        var json = raw.formatKeys()
        for (i, item) in json {
            if i.capitalizedString == className  {
                if let dictionary = item as? [String: AnyObject] {
                    return self.self(dictionary)
                }
            } else if i.capitalizedString == className.pluralize() {
                if let list = item as? [[String: AnyObject]] {
                    var passengers = [Passenger]()
                    for dictionary in list {
                        passengers.append(self.self(dictionary))
                    }
                    return passengers
                }
            }
        }
    
        return self.self(json)
    }
    
    public func getRouteComponents() -> [String] {
        return [self.dynamicType.className]
    }
    
    public func getType() -> Passenger.Type {
        return self.dynamicType
    }
    
    public func getFieldValue(name: String) -> AnyObject? {
        if let mirror = mirrors[name] {
            return getMirrorValue(mirror)
        }
        
        return nil
    }
    
    public func setPathVariables(var path: String) -> String {
        if let matches = path.scan("(?<=:)[\\w_\\.\\d]+(?=\\/|$)") {
            //println("Matches: \(matches)")
            for arrMatch in matches {
                for match in arrMatch {
                    //println("Match \(match)")
                    println(mirrors[match])

                    if let mirror = mirrors[match], value: AnyObject = getMirrorValue(mirror) {
                        println("Setting Match \(value)")
                        path = path.gsub(":\(match)", "\(value)")
                    }
                }
            }
        }
        
        return path
    }
    
    public var parent: Router? {
        
        for (name, relationship) in belongsToRelationships {
            if let passenger = relationship.passenger {
                return passenger
            }
        }
        
        return nil
    }
}