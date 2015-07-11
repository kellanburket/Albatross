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
    * String
    * Character
    * NSDate
    * NSURL
    * UIColor
    * Image
    * Passenger
    * Array<T>
    * Dictionary<T, E>
*/

public class Passenger: BaseObject, Router {
    public var id: Int = 0
    
    class var className: String {
        return "\(self.self)".split(".").last ?? ""
    }
    
    internal func asMethodName() -> String {
        return "\(self.dynamicType)".split(".").last?.decapitalize() ?? ""
    }
    
    internal lazy var hasManys: [String: HasManyRouter] = {
        return self.getRelationships(HasManyRouter.self)
    }()

    internal lazy var hasOnes: [String: HasOneRouter] = {
        return self.getRelationships(HasOneRouter.self)
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
    
    public var parent: Passenger? {
        
        for (name, relationship) in belongsTos {
            if let passenger = relationship.get() {
                return passenger
            }
        }
        
        return nil
    }
    
    required public init(_ properties: Json = Json()) {
        super.init()


        for (name, relationship) in relationships {
            //println("\tSetting Relationship Owner: \(self.endpoint) \(relationship.kind)-> \(relationship.endpoint)")
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
                        //println("\t\tSetting \(k)")
                        relationships[key] = value
                    } else if let subdictionary = value as? [String: Any] {
                        f(subdictionary)
                    } else {
                        //println("Does not conform to Dictionary/\(T.self)")
                    }
                }
            }
        }
        
        for (name, mirror) in self.mirrors {
            //println("\(name):")
            if let mirrorValue = parseMirror(mirror) {
                if let dictionary = mirrorValue as? [String: Any] {
                    Y(lambda)(dictionary)
                } else if let value = mirrorValue as? T {
                    relationships[name] = value
                }
            }
        }
        
        return relationships
    }
    
    private class func getRouter(params: Json = Json()) -> Router {
        return PseudoRouter(type: self)
    }

    final public func save(onComplete: AnyObject? -> Void) {
        Api.shared.save(self, params: serialize() as? Json ?? Json(), onComplete: onComplete)
    }

    public func create(onComplete: onPassengerRetrieved) {
        Api.shared.create(self, params: serialize() as? Json ?? Json()) { [unowned self] obj in
            if let passenger = obj as? Passenger {
                onComplete(passenger)
            } else {
                onComplete(nil)
            }
        }
    }
    
    public func destroy(onComplete: AnyObject? -> Void) {
        Api.shared.destroy(self, onComplete: onComplete)
    }

    public func doAction(endpoint: String, params: [String: AnyObject], onComplete: AnyObject? -> Void) {
        Api.shared.request(self, endpoint: endpoint, params: params, handler: onComplete)
    }

    public class func doAction(endpoint: String, params: [String: AnyObject], onComplete: AnyObject? -> Void) {
        Api.shared.request(getRouter(params: params), endpoint: endpoint, params: params, handler: onComplete)
    }

    final public class func find(id: Int, onComplete: onPassengerRetrieved) {
        Api.shared.find(self(["id": id])) { obj in
            if let record = obj as? Passenger {
                onComplete(record)
            } else {
                onComplete(nil)
            }
        }
    }

    final public class func create(params: [String: AnyObject], onComplete: onPassengerRetrieved) {
        self(params).create(onComplete)
    }
    
    final public class func create(onComplete: onPassengerRetrieved) {
        self.create([String: AnyObject](), onComplete: onComplete)
    }

    final public class func list(onComplete: onPassengersRetrieved) {
        Api.shared.list(self.getRouter()) { records in
            if let arr = records as? [Passenger] {
                onComplete(arr)
            } else {
                onComplete(nil)
            }
        }
    }
    
    final public class func search(params: [String: AnyObject], onComplete: onPassengersRetrieved) {
        Api.shared.search(self.getRouter(), params: params) { records in
            if let arr = records as? [Passenger] {
                onComplete(arr)
            } else {
                onComplete(nil)
            }
        }
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

    private func unserialize(var data: [String: AnyObject]) {
        //println("Unserializing \(self.endpoint)")

        for (name, mirror) in mirrors {
            if !(name =~ "\\.storage$") {
                //println("\t\(name)")
                setMirrorValue(name, mirror: mirror, data: data)
            }
        }

        println("Unserializing Finished for \(self.endpoint)")
    }
    
    internal func getFieldValue(name: String) -> AnyObject? {
        if let mirror = mirrors[name] {
            return getMirrorValue(mirror)
        }
        
        return nil
    }

    private func setMirrorValue(name: String, mirror: MirrorType, data: [String:AnyObject]) {
        let type = mirror.valueType
        
        if let item: AnyObject = data[name], value: AnyObject = parseMirrorValue(name, value: item, type: mirror.valueType, mirror: mirror) {
            //println("\tSetting \(name) : \(value)")
            setValue(value, forKey: name)
        } else {
            if let value: AnyObject = data[name] {
                //println("\tNot Setting \(name) '\(value)' for \(mirror.valueType)")
            }
        }
    }
    
    private func parseMirrorValue(name: String, value: AnyObject?, type: Any.Type, mirror: MirrorType) -> AnyObject? {
        //println("Fetching \(name) : \(type)")

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
            } else if type is Image.Type || type is Optional<Image>.Type {
                //Load New Media
                if let url = NSURL(string: value) {
                    return Image(url: url)
                }
                
            } else if type is NSURL.Type || type is Optional<NSURL>.Type {
                if let url = NSURL(string: value) {
                    //println("\tSetting NSURL")
                    return url
                } else {
                    //println("\tNot a valid url: \(value)")
                }
            } else if type is NSAttributedString.Type || type is Optional<NSAttributedString>.Type {
                //println("\tSetting NSAttributedString")
                return value
            } else if type is UIColor.Type || type is Optional<UIColor>.Type {
                //return UIColor.parse(Int(i))
            } else {
                //println("Can't parse string '\(value)' for '\(type)'")
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
            if type is Router.Type {
                //println("Constructing Type \(type)")
                return constructType(name, mirror: mirror, values: values)
            } else {
                
                //if (type is Dictionary<String, NSObject>.Type || type is Dictionary<String, Router>.Type) && mirror.count > 0 {
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
                                        hash[key] = pvalue
                                    } else {
                                        //Set Original Value
                                        hash[key] = hashValue.value as? AnyObject
                                    }
                                }
                            }
                        }
                        return hash
                    } else {
                        println("Can't parse \(value)")
                    }
                } else {
                    //Structs, Tuples, and Non Router Classes won't be set
                    println("'\(type)' not permitted for value '\(value)'")
                }
            }
        } else if let values = value as? [AnyObject] {
            println("\tarray: \(type) : \(values.dynamicType)")
            if values.count > 0 {
                var arr = [AnyObject]()
                
                for value in values {
                    if let subtype = getSubtype(type) {
                        if let parsedValue: AnyObject = parseMirrorValue(name, value: value, type: subtype, mirror: mirror) {
                            arr << parsedValue
                        }
                    } else if let value = value as? [String: AnyObject] {
                        if let obj = constructType(name, mirror: mirror, values: value) {
                            arr << obj
                        } else {
                            println("\tCould Not Construct Subtype \(mirror.valueType)")
                        }
                    } else {
                        println("\tCould Not Match Subtype \(type)")
                    }
                }
                
                return arr.count > 0 ? arr : nil
            }
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
            return nil
        }

        //fatalError("Cannot parse value of type \(fieldMirror.valueType)")
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
        //println("\tMirror <\(self.dynamicType).\(name)>")
        //println("\t\tCount: \(mirror.count)")
        //println("\t\tDisposition: \(self.dynamicType.getDisposition(mirror.disposition))")
        //println("\t\tValue Type: \(mirror.valueType)")

        if let relationship = mirror.value as? RelationshipRouter {
            
            if let obj = relationship.construct(values, node: nil) as? Passenger {
                relationship.registerPassenger(obj)
                return nil
            }
            /*
            let clzName = "\(Api.shared.namespace).\(relationship.endpoint.capitalize())"
            println("Constructing \(clzName)")
            if let obj = ClassReflektor.create(clzName, initializer: "init:", argument: values) as? Passenger {
                if let relationship = mirror.value as? RelationshipRouter {
                    //println("Registering (\(clzName))")
                    relationship.registerPassenger(obj)
                    return nil
                } else if mirror.value is Optional<Passenger>.Type {
                    println("Setting (\(clzName))")
                    return obj
                }
            }
            */
        
            //println("Could not construct '\(clzName)'")
            return nil
        }
        
        println("\(mirror.valueType) is not an instance of RelationshipRouter")
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
            output += describePropertyPrimitive(value)
        }
        
        return output
    }

}