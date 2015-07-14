//
//  Passenger.swift
//  Pods
//
//  Created by Kellan Cummings on 6/10/15.
//
//

import Foundation
//import Reflektor
import Wildcard

/**
    When extending the Passenger class, please note that all so-called primitive types with the exception of String (e.g., Int, Float, Double, Bool) must be declared as non-optionals or an `NSUnknownKeyException` will be thrown when attempting to set values. We hope that future releases of Swift will expand the reflection API and allow for more robust key-value coding.

    Currently the following types are supported:
    
    * Int, UInt, Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64
    * Bool
    * Float, Double
    * String
    * Character
    * NSDate
    * NSURL
    * UIColor
    * NSAttributedString
    * Image
    * Passenger
    * Array<T>
    * Dictionary<T, E>
*/

public class Passenger: BaseObject, Router {
    
    public class func api() -> String? {
        return nil
    }

    class var className: String {
        return "\(self.self)".split(".").last ?? ""
    }
    
    internal func asMethodName() -> String {
        return "\(self.dynamicType)".split(".").last?.decapitalize() ?? ""
    }
    
    internal lazy var hasManys: [String: HasManyRouter] = {
        return self.getRelationships(HasManyRouter.self)
    }()

    internal lazy var hasOnes: [String: Passenger] = {
        return self.getRelationships(Passenger.self)
    }()
    
    internal lazy var belongsTos: [String: BelongsToRouter] = {
        return self.getRelationships(BelongsToRouter.self)
    }()

    internal lazy var relationships: [String: RelationshipRouter] = {
        return self.getRelationships(RelationshipRouter.self)
    }()
    
    internal var endpoint: String {
        return self.dynamicType.className
    }
    
    public var parent: Passenger?
    
    required public init(_ properties: Json = Json()) {
        super.init()


        for (name, relationship) in relationships {
            relationship.setOwner(self)
        }
        
        unserialize(properties)
    }

    internal func construct(args: AnyObject, node: String? = nil) -> AnyObject {
        return self.dynamicType.parse(args, node: node)
    }
    
    internal class func parse(raw: AnyObject, node: String? = nil) -> AnyObject {
        if let arr = raw as? [AnyObject] {

            if let list = arr as? [Json] {
                var passengers = [Passenger]()

                for dictionary in list {
                    passengers << self.self(dictionary.formatKeys())
                }

                return passengers
            }
            
        } else if let hash = raw as? [String: AnyObject] {
            var hashJson = hash.formatKeys()

            for (i, item) in hashJson {
                if let node = node {
                    if i == node {
                        if let dictionary = item as? [String: AnyObject] {
                            return self.self(dictionary)
                        } else if let list = item as? [[String: AnyObject]] {
                            var passengers = [Passenger]()
                            
                            for dictionary in list {
                                passengers << self.self(dictionary)
                            }
                            
                            return passengers
                        }
                    }
                } else {
                    if i.capitalize() == className  {
                        if let dictionary = item as? [String: AnyObject] {
                            return self.self(dictionary)
                        }
                    } else if i.capitalize() == className.pluralize() {
                        if let list = item as? [[String: AnyObject]]  {
                            var passengers = [Passenger]()
                            for dictionary in list {
                                passengers << self.self(dictionary)
                            }
                            return passengers
                        }
                    }
                }
            }

            return self.self(hashJson)
        }

        println("WARNING: cannot parse return values!")
        return self.self(Json())
    }
    
    private func getRelationships<T>(type: T.Type) -> [String: T] {
        var relationships = [String: T]()

        var lambda: (Dictionary<String, Any> -> Void) -> (Dictionary<String, Any> -> Void) = { f in
            return { dictionary in
                for (key, value) in dictionary {
                    if let value = value as? T {
                        if let relationship = value as? RelationshipRouter {
                            relationships[relationship.endpoint.decapitalize()] = value
                        }
                    } else if let subdictionary = value as? [String: Any] {
                        f(subdictionary)
                    } else {
                        //println("Does not conform to Dictionary/\(T.self)")
                    }
                }
            }
        }
        
        for (name, mirror) in self.mirrors {
            if let mirrorValue = parseMirror(mirror) {
                if let dictionary = mirrorValue as? [String: Any] {
                    Y(lambda)(dictionary)
                } else if let value = mirrorValue as? T {
                    //println("\t\tSetting \(self.endpoint)")
                    
                    if let relationship = value as? RelationshipRouter {
                        relationships[relationship.endpoint.decapitalize()] = value
                    }
                }
            }
        }
        
        return relationships
    }
        
    public func serialize() -> AnyObject? {
        var serial = [String: AnyObject]()
        
        for (fieldName, fieldMirror) in mirrors {
            if let value: AnyObject = getMirrorValue(fieldMirror) {
                //println("Serializing \(fieldName), \(value)")
                serial[fieldName] = value
            }
        }
        
        //println(serial)
        return serial
    }

    public func update(var data: Json, parent: Passenger?) {
        
        if let parent = parent {
            self.parent = parent
        }
        
        unserialize(data)
    }
    
    private func unserialize(data: Json) {
        //println("Unserializing \(self.endpoint)")
        //println(data)

        for (name, mirror) in mirrors {
            if !(name =~ "\\.storage$") {
                //println("\t\(name)")
                setMirrorValue(name, mirror: mirror, data: data)
            }
        }

        //println("Unserializing Finished for \(self.endpoint)")
    }
    
    internal func getProperty(name: String) -> AnyObject? {
        if let mirror = mirrors[name] {
            if let value: AnyObject = getMirrorValue(mirror) {
                return value
            } else {
                println(self)
                fatalError("Property '\(name)' unset for '\(endpoint)'")
            }
        } else {
            fatalError("Unable to get value for property `\(endpoint)`.`\(name)`")
        }
        
        return nil
    }

    private func setMirrorValue(name: String, mirror: MirrorType, data: [String:AnyObject]) {
        let type = mirror.valueType
        
        if let item: AnyObject = data[name] {
            if let value: AnyObject = parseMirrorValue(name, value: item, type: mirror.valueType, mirror: mirror) {
                //println("\tSetting \(name) : \(value)")
                setValue(value, forKey: name)
            } else {
                //println("\tNot Setting \(name) for \(mirror.valueType)")
            }
        } else {
            //println("\tNil Value for \(name) : \(data[name]) for \(mirror.valueType)")
        }
    }
    
    private func parseMirrorValue(name: String, value: AnyObject?, type: Any.Type, mirror: MirrorType) -> AnyObject? {
        
        
        //println("\t\tFetching \(name) : \(type)")

        if value == nil {
            return nil
        } else if let value = value as? Int {
            //println("Setting Mirror (Int) \(name) : \(value)")
            if type is Int.Type || type is UInt.Type || type is UInt8.Type || type is UInt16.Type || type is UInt32.Type || type is UInt64.Type || type is Int8.Type || type is Int16.Type || type is Int32.Type || type is Int64.Type {
                //println("\tSetting (Int)")
                return value
            } else if type is Bool.Type {
                //println("\tSetting (Bool)")
                return value == 1
            }
            
        } else if let value = value as? String {
            //println("\tSetting (String) \(name)")
            
            if type is String.Type || type is Optional<String>.Type {
                return value
            } else if type is Character.Type {
                return value
            } else if type is NSDate.Type || type is Optional<NSDate>.Type {
                //println("value: \(value) -> \(value.toDate())")
                if let date = value.toDate() {
                    //println("\tSetting NSDate")
                    return date
                }
            } else if type is Image.Type {
                //Load New Media
                if let url = NSURL(string: value) {
                    //println("\tSetting Image: \(value)")
                    return Image(url: url)
                } else {
                    println("\t\t\tNot a valid url for image: \(value)")
                }
                
            } else if type is NSURL.Type || type is Optional<NSURL>.Type {
                if let url = NSURL(string: value) {
                    return url
                } else {
                    println("\t\t\tNot a valid url: \(value)")
                }
            } else if type is NSAttributedString.Type || type is Optional<NSAttributedString>.Type {
                //println("\tSetting NSAttributedString")
                return value
            } else if type is UIColor.Type || type is Optional<UIColor>.Type {
                //return UIColor.parse(Int(i))
            } else {
                //println("\t\t\tCan't parse string '\(value)' for '\(type)'")
            }
        } else if let value = value as? Double {
            if type is Float.Type {
                //println("\tSetting Float")
                return value
            } else if type is Double.Type {
                //println("\tSetting Double")
                return value
            }
        } else if let value = value as? Passenger {
            //println("\tSetting Passenger")
            return value
        } else if let values = value as? [String: AnyObject] {
            //println("Type \(type)")
            
            if mirror.disposition == .Optional {
                println("\t'\(name)' is optional.")
                println("\t\tCount: \(mirror.count)")
                println("\t\tDisposition: \(self.dynamicType.getDisposition(mirror.disposition))")
                println("\t\tValue: \(mirror.value)")
                println("\t\tValue Type: \(mirror.valueType)\n")
                
            } else if type is Router.Type {
                //println("\tConstructing Router")
                return constructType(name, mirror: mirror, values: values)
            } else {
                
                if let dictionary = value as? [String: AnyObject] {
                    var hash = [String: AnyObject]()
                    if let data = value as? Json {
                        for i in 0..<mirror.count {
                            let (_, submirror) = mirror[i]
                            
                            
                            if submirror.count == 2 {
                                let (_, hashKey) = submirror[0]
                                let (_, hashValue) = submirror[1]
                                
                                if let key = hashKey.value as? String {
                                    if let pvalue: AnyObject = parseMirrorValue(key, value: data[key], type: hashValue.valueType, mirror: hashValue) {
                                        println("Setting Key \(hashValue.valueType)")

                                        hash[key] = pvalue
                                    } else {
                                        //println("Setting Original Value \(hashValue.valueType)")
                                        //Set Original Value
                                        hash[key] = hashValue.value as? AnyObject
                                    }
                                } else {
                                    println("\tHash key for '\(name)' is not a string.")
                                    println("\t\tCount: \(mirror.count)")
                                    println("\t\tDisposition: \(self.dynamicType.getDisposition(mirror.disposition))")
                                    println("\t\tValue: \(mirror.value)")
                                    println("\t\tValue Type: \(mirror.valueType)\n")
                                }
                            } else {
                                println("\t\(name) does not have count == 2.")
                                println("\t\tCount: \(mirror.count)")
                                println("\t\tDisposition: \(self.dynamicType.getDisposition(mirror.disposition))")
                                println("\t\tValue: \(mirror.value)")
                                println("\t\tValue Type: \(mirror.valueType)\n")
                            }
                            
                        }
                        return hash
                    } else {
                        println("\tCan't parse \(name)")
                        println("\t\tCount: \(mirror.count)")
                        println("\t\tDisposition: \(self.dynamicType.getDisposition(mirror.disposition))")
                        println("\t\tValue: \(mirror.value)")
                        println("\t\tValue Type: \(mirror.valueType)\n")
                    }
                } else {
                    //Structs, Tuples, and Non Router Classes won't be set
                    println("\t'\(type)' not permitted for '\(name)'")
                    println("\t\tCount: \(mirror.count)")
                    println("\t\tDisposition: \(self.dynamicType.getDisposition(mirror.disposition))")
                    println("\t\tValue: \(mirror.value)")
                    println("\t\tValue Type: \(mirror.valueType)\n")
                }
            }
        } else if let values = value as? [AnyObject] {
            if values.count > 0 {
                //println("\tarray: \(type) : \(values.dynamicType)")

                var arr = [AnyObject]()
                
                for value in values {
                    if let subtype = getSubtype(type) {
                        if let parsedValue: AnyObject = parseMirrorValue(name, value: value, type: subtype, mirror: mirror) {
                            //println("\t\tappending \(parsedValue)")
                            arr << parsedValue
                        } else {
                            println("\t\tCould not set '\(value)'(\(subtype))")
                        }
                    } else if let value = value as? [String: AnyObject] {
                        if let obj = constructType(name, mirror: mirror, values: value) {
                            //println("\t\tappending <\(mirror.valueType)>")
                            arr << obj
                        }
                    } else {
                        println("\t\tCould Not Match Subtype \(type)")
                    }
                }
                
                return arr.count > 0 ? arr : nil
            }
        } else {
            /*
            println("\tUnable to parse '\(name)'.")
            println("\t\tCount: \(mirror.count)")
            println("\t\tDisposition: \(self.dynamicType.getDisposition(mirror.disposition))")
            println("\t\tValue: \(mirror.value)")
            println("\t\tValue Type: \(mirror.valueType)\n")
            */
        }
        
        //println("Unable to Parse \(name): \(type)")
        return nil
    }
    
    private func getMirrorValue(fieldMirror: MirrorType) -> AnyObject? {
        if let value: AnyObject = fieldMirror.value as? AnyObject {
            if let value = value as? Router {
                //println("Getting Router[\(fieldMirror.valueType)]")
                return nil
                //return value.serialize()
            } else if let array = value as? [AnyObject] {
                //println("Getting Array[\(fieldMirror.valueType)]")
                var serialized = [AnyObject]()
                for value in array {
                    if let serial: AnyObject = getMirrorValue(reflect(value)) {
                        serialized << serial
                    }
                }
                
                return serialized
            } else if let dictionary = value as? [String: AnyObject] {
                //println("Getting Dictionary[\(fieldMirror.valueType)]")
                var serialized = [String: AnyObject]()
                for (key, value) in dictionary {
                    if let serial: AnyObject = getMirrorValue(reflect(value)) {
                        serialized[key] = serial
                    }
                }
                
                return serialized
            } else {
                //println("Getting Primitive[\(fieldMirror.valueType)][\(fieldMirror.value)]")
                if let value = value as? NSDate {
                    return value.format("yyyy-MM-dd hh:mm:ss")
                } else {
                    return value
                }
            }
        } else if fieldMirror.disposition == .Optional { //
            if fieldMirror.count > 0 {
                //println("Getting Optional[\(fieldMirror.valueType)]")
                let (enumType, submirror) = fieldMirror[0]
                
                if enumType == "Some" {
                    //println("\tSome \(submirror.value)")
                    return getMirrorValue(submirror)
                } else {
                    //println("\tValue is empty \(submirror.value)")
                    return nil //Return nil if value is empty
                }
            } else {
                //println("\tCount is 0 \(fieldMirror.value)")
                return nil //Return nil if value is empty
            }
        } else if fieldMirror.count > 0 {
            //println("\tFieldMirror Count = \(fieldMirror.count)")
            var serialized = [String: AnyObject]()
            
            for i in 0..<fieldMirror.count {
                let (_, submirror) = fieldMirror[i]
                //println("\t\tSubmirror Count = \(submirror.count)")
                if submirror.count == 2 {
                    let (_, hashKey) = submirror[0]
                    let (_, hashValue) = submirror[1]
                    
                    if let key = hashKey.value as? String {
                        if let pvalue: AnyObject = getMirrorValue(hashValue) {
                            serialized[key] = pvalue
                        } else {
                            //Set Original Value
                            serialized[key] = hashValue.value as? AnyObject
                        }
                    }
                }
            }
            
            return serialized
        } else {
            println("\tUnable to parse Mirror Value.")
            println("\t\tCount: \(fieldMirror.count)")
            println("\t\tDisposition: \(self.dynamicType.getDisposition(fieldMirror.disposition))")
            println("\t\tValue: \(fieldMirror.value)")
            println("\t\tValue Type: \(fieldMirror.valueType)\n")

            return nil
        }
    }
    
    override internal func parseOptionalMirror(mirror: MirrorType) -> Any? {
        if let value = super.parseOptionalMirror(mirror) {
            if mirror[0].1.valueType is Dictionary<String, RelationshipRouter>.Type {
                return nil
            }
            
            //println("\(mirror[0].1.valueType)")
            
            return value
        }
    
        return nil
    }
    
    private func constructType(name: String, mirror: MirrorType, values: [String: AnyObject]) -> Passenger? {
        if let relationship = mirror.value as? RelationshipRouter {
            
            if let obj = relationship.construct(values, node: nil) as? Passenger {
                //println("\tRegistering Passenger \(obj.endpoint)")
                relationship.registerPassenger(obj)
                return nil
            }
            
        } else if let passenger = mirror.value as? Passenger {
            passenger.update(values, parent: self)
            return nil
        }
        
        println("Could not construct '\(mirror.valueType)' : \(mirror.value)")
        return nil
    }
    
    internal func getOwnershipHierarchy() -> [Router] {
        var components: [Router] = [self]
        var router: Router = self
        
        while let parent = router.parent {
            components << parent
            router = parent
        }
        
        return components.reverse()
    }
    
    override internal func describeSelf(_ tabs: Int = 0) -> String {
        var output = "<\(self.endpoint)>"
        
        for (name, mirror) in mirrors {
            if let value: AnyObject = getMirrorValue(mirror) {
                output += "\n" + "\t".repeat(tabs + 1) + "\(name): "
                output += describeProperty(value, tabs + 1)
            }
        }
        
        return output
    }
    
    override internal func describeProperty(value: AnyObject, _ tabs: Int = 0) -> String {
        var output = ""

        if let arr = value as? [AnyObject] {
            output += describePropertyArray(arr, tabs + 1)
        } else if let hash = value as? [String: AnyObject] {
            output += describePropertyDictionary(hash, tabs + 1)
        } else if let obj = value as? Router {
            output += "<\(obj.endpoint)>"
        } else {
            //output += describePropertySerializable(value)
            output += describePropertyPrimitive(value)
        }
        
        return output
    }

}