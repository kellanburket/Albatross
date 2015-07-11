//
//  Base.swift
//  Pods
//
//  Created by Kellan Cummings on 7/10/15.
//
//

import Foundation
import Wildcard

public class BaseObject: NSObject {
    
    internal var mirrors: [String: MirrorType] {
        var mirrors = [String: MirrorType]()
        let reflection = reflect(self)
        
        var writeMirrors: (MirrorType -> Void) -> (MirrorType -> Void) = { f in
            return { reflection in
                for i in 0..<reflection.count {
                    let (name, mirror) = reflection[i]
                    //println("\tMirror <\(self.dynamicType).\(name)>")
                    //println("\t\tCount: \(mirror.count)")
                    //println("\t\tDisposition: \(self.dynamicType.getDisposition(mirror.disposition))")
                    //println("\t\tValue Type: \(mirror.valueType)")

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

    override public var description: String {
        return describeSelf()
    }
    
    internal func describeSelf(_ tabs: Int = 0) -> String {
        return ""
    }

    internal func parseMirror(mirror: MirrorType) -> Any? {
        if mirror.count >= 1 && mirror.disposition == .Optional {
            return parseOptionalMirror(mirror)
        } else if mirror.count >= 1 && mirror.disposition == .Class {
            return mirror.value //parseObjectMirror(mirror)
        } else if mirror.count >= 1 && mirror.disposition == .KeyContainer {
            return parseDictionaryMirror(mirror)
        } else if let value: AnyObject = mirror.value as? AnyObject {
            //println("Primitive Mirror")
            //println("\tCount: \(mirror.count)")
            //println("\tValue: \(mirror.value)")
            //println("\tValue Type: \(mirror.valueType)")
            //println("\tSummary: \(mirror.summary)")
            return mirror.value
        }
        
        //println("Nil Mirror")
        //println("\tCount: \(mirror.count)")
        //println("\tValue: \(mirror.value)")
        //println("\tValue Type: \(mirror.valueType)")
        //println("\tSummary: \(mirror.summary)")
        
        return nil
        
    }
    
    internal func parseDictionaryMirror(mirror: MirrorType) -> Any? {
        //println("\tDictionary Mirror")
        var hash = [String: Any]()
        
        for i in 0..<mirror.count {
            let (mirrorIndex, tupleMirror) = mirror[i]
            
            if tupleMirror.count == 2 && tupleMirror.disposition == .Tuple {
                var keyMirror = tupleMirror[0].1
                var valueMirror = tupleMirror[1].1
                
                if let key = keyMirror.value as? String {
                    hash[key] = parseMirror(valueMirror)
                } else {
                    println("\t\tKey Mirror not a String")
                    println("\t\t\tCount: \(keyMirror.count)")
                    println("\t\t\tDisposition: \(self.dynamicType.getDisposition(keyMirror.disposition))")
                    println("\t\t\tValue: \(keyMirror.value)")
                    println("\t\t\tValue Type: \(keyMirror.valueType)")
                    println("\t\t\tSummary: \(keyMirror.summary)")
                }
            } else {
                println("\t\tName: \(mirrorIndex)")
                println("\t\t\tCount: \(tupleMirror.count)")
                println("\t\t\tDisposition: \(self.dynamicType.getDisposition(tupleMirror.disposition))")
                println("\t\t\tValue: \(tupleMirror.value)")
                println("\t\t\tValue Type: \(tupleMirror.valueType)")
                println("\t\t\tSummary: \(tupleMirror.summary)")
            }
        }
        
        return hash.count > 0 ? hash : nil
    }
    
    internal func parseOptionalMirror(mirror: MirrorType) -> Any? {
        if mirror.count == 1 {
            let (optionalType, optionalMirror) = mirror[0]
            
            if optionalType == "Some" {                
                return parseMirror(optionalMirror)
                /*
                println("OptionalMirror(\(optionalType)) \(optionalMirror.valueType)")
                println("\t\tCount: \(optionalMirror.count)")
                println("\t\tDisposition: \(getDisposition(optionalMirror.disposition))")
                println("\t\tValue: \(optionalMirror.value)")
                println("\t\tValue Type: \(optionalMirror.valueType)")
                println("\t\tSummary: \(optionalMirror.summary)")
                */
            } else {
                println("OptionalMirror(\(optionalType)) \(optionalMirror.valueType)")
                println("\t\tCount: \(optionalMirror.count)")
                println("\t\tDisposition: \(self.dynamicType.getDisposition(optionalMirror.disposition))")
                println("\t\tValue: \(optionalMirror.value)")
                println("\t\tValue Type: \(optionalMirror.valueType)")
                println("\t\tSummary: \(optionalMirror.summary)")
            }
        } else {
            println("\tOptional Mirror (Count > 1): \(mirror.valueType)")
            println("\t\tCount: \(mirror.count)")
            println("\t\tValue: \(mirror.value)")
            println("\t\tValue Type: \(mirror.valueType)")
            println("\t\tSummary: \(mirror.summary)")
        }
        
        return nil
    }
    
    internal class func getDisposition(disposition: MirrorDisposition) -> String {
        switch disposition {
            case .Struct: return "Struct"
            case .Class: return "Class"
            case .Enum: return "Enum"
            case .Tuple: return "Tuple"
            case .Aggregate: return "Aggregate"
            case .IndexContainer: return "IndexContainer"
            case .KeyContainer: return "KeyContainer"
            case .MembershipContainer: return "Membership Container"
            case .Container: return "Container"
            case .Optional: return "Optional"
            case .ObjCObject: return "Objective C Object"
            default: return "Unknown"
        }
    }

    internal func getSubtype(type: Any.Type) -> Any.Type? {
        if type is Array<Int>.Type {
            return Array<Int>.self
        } else if type is Array<UInt>.Type {
            return Array<UInt>.self
        } else if type is Array<Int8>.Type {
            return Array<Int8>.self
        } else if type is Array<UInt8>.Type {
            return Array<UInt8>.self
        } else if type is Array<Int16>.Type {
            return Array<Int16>.self
        } else if type is Array<UInt16>.Type {
            return Array<UInt16>.self
        } else if type is Array<Int32>.Type {
            return Array<Int32>.self
        } else if type is Array<UInt32>.Type {
            return Array<UInt32>.self
        } else if type is Array<Int64>.Type {
            return Array<Int64>.self
        } else if type is Array<UInt64>.Type {
            return Array<UInt64>.self
        } else if type is Array<String>.Type {
            return Array<String>.self
        } else if type is Array<Character>.Type {
            return Array<Character>.self
        } else if type is Array<Bool>.Type {
            return Array<Bool>.self
        } else if type is Array<Float>.Type {
            return Array<Float>.self
        } else if type is Array<Double>.Type {
            return Array<Double>.self
        } else if type is Array<NSURL>.Type {
            return Array<NSURL>.self
        } else if type is Array<UIColor>.Type {
            return Array<UIColor>.self
        } else if type is Array<NSAttributedString>.Type {
            return Array<NSAttributedString>.self
        } else if type is Array<NSDate>.Type {
            return Array<NSDate>.self
        }
        
        return nil
    }
    
    internal func describeProperty(value: AnyObject, _ tabs: Int = 0) -> String {
        var output = ""
        
        if let arr = value as? [AnyObject] {
            output += describePropertyArray(arr, tabs + 1)
        } else if let hash = value as? [String: AnyObject] {
            output += describePropertyDictionary(hash, tabs + 1)
        } else {
            output += describePropertyPrimitive(value)
        }
        
        return output
    }
    
    internal func describePropertyArray(arr: [AnyObject], _ tabs: Int = 0) -> String {
        var output = ""
        
        for value in arr {
            output += "\n" + "\t".repeat(tabs)
            output += describeProperty(value, tabs + 1)
            output += "\n" + "\t".repeat(tabs) + "---------------------------"
        }
        
        return output
    }
    
    internal func describePropertyDictionary(hash: [String: AnyObject], _ tabs: Int = 0) -> String {
        var output = ""
        
        for (key, value) in hash {
            output += "\n" + "\t".repeat(tabs) + "\(key): "
            output += describeProperty(value, tabs + 1)
        }
        
        return output
    }
    
    internal func describePropertyPrimitive(value: AnyObject) -> String {
        return "\(value)"
    }
}
