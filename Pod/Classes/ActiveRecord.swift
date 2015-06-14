//
//  ActiveRecord.swift
//  Pods
//
//  Created by Kellan Cummings on 6/10/15.
//
//

import Foundation

public class ActiveRecord: NSObject {

    public var id: Int?

    public func save(params: [String: AnyObject]) {
        for (key, value) in params {
            if parse(key) != nil {
                setValue(value, forKey: key)
            }
        }
    }
    
    public class func find(id: Int, onComplete: (AnyObject) -> ()) {
        Api.shared.find(self.self, id: id, onComplete: onComplete)
    }
    
    public func create(onComplete: (AnyObject) -> ()) {
        Api.shared.create(self.dynamicType, data: serialize(), onComplete: onComplete)
    }
    
    public func destroy(onComplete: (AnyObject) -> ()) {
        if let mId = self.id {
            Api.shared.destroy(self.dynamicType, id: mId, onComplete: onComplete)
        }
    }
    
    public class func fetch(onComplete: (AnyObject) -> ()) {
        Api.shared.fetch(self.self, onComplete: onComplete)
    }
    
    public func serialize() -> [String: AnyObject] {
        var serial = [String:AnyObject]()
        let copy = reflect(self)
        for index in 0 ..< copy.count {
            let (fieldName, fieldMirror) = copy[index]
            serial[fieldName] = valueForKey(fieldName)
        }
        
        return serial
    }
    
    func parse(key: String) -> AnyObject? {
        let copy = reflect (self)
        for index in 0 ..< copy.count {
            let (fieldName, fieldMirror) = copy[index]
            
            if (fieldName == key) {
                return valueForKey(fieldName)
            }
        }
        
        return nil
    }
}