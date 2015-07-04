//
//  Passenger.swift
//  Pods
//
//  Created by Kellan Cummings on 6/10/15.
//
//

import Foundation
import Reflektor
import Wildcard

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
        return "\(self.dynamicType)".split(".").last?.decapitalize ?? ""
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
    
    internal var mirrors: [String: MirrorType] {
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
    }
    
    private func getRelationships<T>(type: T.Type) -> [String: T] {
        var relationships = [String: T]()
        //println("RELATIONSHIP: \(Optional<T>.self)")
        for (name, mirror) in self.mirrors {
            if let relationship = mirror.value as? T {
                relationships[name] = relationship
            }
        }
        
        return relationships
    }
    
    private class func getRouter(params: [String: AnyObject] = [String: AnyObject]()) -> Router {
        return PseudoRouter(type: self)
    }
    
    required public init(_ properties: [String: AnyObject]) {
        super.init()
        unserialize(properties)
        
        for (name, mirror) in mirrors {
            if var relationship = mirror.value as? RelationshipRouter {
                //println("RELATIONSHIP \(name) : \(relationship)")
                relationship.owner = self
            } else {
                
            }
        }
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
    
    final public class func upload() {
        requestUploadToken { (data, response, error) in
            //println("Request Token Upload")
            if let json = data.toJSON() {
                if let token = json["upload_token"] as? String {
                    //println("Request Token Returned: \(token)")
                    self.uploadImage(token, filepath: filepath) { (data, response, error) in
                        if let morejson = data.toJSON() {
                            if let uploads = morejson["uploads"] as? NSDictionary {
                                if let file0 = uploads["file0"] as? NSDictionary {
                                    if let imageId = file0["image_id"] as? Int {
                                        //println("Image ID Returned: \(imageId)")
                                        Http.post(
                                            URL,
                                            params: ["image_id": imageId],
                                            delegate: delegate,
                                            action: action
                                        )
                                    }
                                }
                            }
                        } else {
                            //println("Data is null")
                        }
                    }
                }
            }
        }
    }
    
    private func unserialize(var data: [String:AnyObject]) {
        if let d = data[self.dynamicType.className.lowercaseString] as? [String:AnyObject]  {
            data = d
        }
        
        for (name, mirror) in mirrors {
            setMirrorValue(name, mirror: mirror, data: data)
        }
    }
    
    public func serialize() -> [String: AnyObject] {
        var serial = [String: AnyObject]()
        
        for (fieldName, fieldMirror) in mirrors {
            if let value: AnyObject = getMirrorValue(fieldMirror) {
                serial[fieldName] = value
            }
        }
        
        //println(serial)
        return serial
    }

    private func setMirrorValue(name: String, mirror: MirrorType, data: [String:AnyObject]) {
        let type = mirror.valueType
        
        //println("Setting \(name) : \(type)")
        //println("Fetching \(name) : \(data[name])")
        
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
                //println("value: \(value) -> \(value.toDate())")
                if let date = value.toDate() {
                    //println("Setting NSDate \(name) : \(value)")
                    self.setValue(date, forKey: name)
                }
            } else if type is Image.Type || type is Optional<Image>.Type {
                //Load New Media
                if let url = "\(value)".toUrl() {
                    self.setValue(Image(url: url), forKey: name)
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
            //println("Setting (\(clzName)) \(type)")
            if type is Router {
                if let obj = ClassReflektor.create(clzName, initializer: "init:", argument: values) as? Passenger {
                    if let relationship = mirror.value as? RelationshipRouter {
                        relationship.registerPassenger(obj)
                    } else if mirror.value is Optional<Passenger>.Type {
                        self.setValue(obj, forKey: name)
                    }
                } else {
                    //For Dictionaries
                }
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

    private func getMirrorObject(fieldMirror: MirrorType) -> Router? {
        //println("GET MIRROR OBJECT: \(fieldMirror). \(fieldMirror[0].0). \(fieldMirror.count)")
        if let passenger = fieldMirror.value as? Router {
            return passenger
        } else if fieldMirror.disposition == .Optional && fieldMirror.count > 0 {
            switch fieldMirror.count {
            case 1:
                //println("Setting Optional: \(fieldName)")
                if fieldMirror[0].0 == "Some" {
                    if let value = fieldMirror[0].1.value as? Router {
                        return value
                    }
                }
            default:
                var arr = [AnyObject]()
            }
        }
        
        return nil
    }
    
    private func getMirrorValue(fieldMirror: MirrorType) -> AnyObject? {
        if let value = fieldMirror.value as? Passenger {
            //println("setting AnyObject \(fieldName): \(value)")
            return value.serialize()
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
        } else if let value: AnyObject = fieldMirror.value as? AnyObject {
            //println("setting AnyObject \(fieldName): \(value)")
            return value
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
    
    public func getType() -> Passenger.Type {
        return self.dynamicType
    }
    
    public func getFieldValue(name: String) -> AnyObject? {
        if let mirror = mirrors[name] {
            return getMirrorValue(mirror)
        }
        
        return nil
    }
    
    public func asEndpointPath() -> String {
        return self.dynamicType.className
    }
        
    public var parent: Router? {
        
        for (name, relationship) in belongsToRelationships {
            println("\(self.dynamicType.className) has relationship to \(name)")
            if let passenger = relationship.passenger {
                return passenger
            }
        }
        
        return nil
    }
    
    public func getOwnershipHierarchy() -> [Router] {
        var components: [Router] = [self]
        var router: Router = self
        
        while let parent = router.parent {
            components.append(parent)
            router = parent
        }
        
        return components.reverse()
    }
}