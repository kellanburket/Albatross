//
//  Model.swift
//  Pods
//
//  Created by Kellan Cummings on 7/12/15.
//
//

import Foundation

public class Model: Passenger {
    
    public var id: Int = 0

    final public func save(onComplete: AnyObject? -> Void) {
        Api.shared(self.dynamicType.api()).save(self, params: serialize() as? Json ?? Json(), onComplete: onComplete)
    }
    
    public func create(onComplete: onPassengerRetrieved) {
        Api.shared(self.dynamicType.api()).create(self, params: serialize() as? Json ?? Json()) { [unowned self] obj in
            if let passenger = obj as? Model {
                onComplete(passenger)
            } else {
                onComplete(nil)
            }
        }
    }
    
    public func destroy(onComplete: AnyObject? -> Void) {
        Api.shared(self.dynamicType.api()).destroy(self, onComplete: onComplete)
    }

    public func doAction(endpoint: String, params: [String: AnyObject], onJsonRetrieved: AnyObject? -> Void) {
        Api.shared(self.dynamicType.api()).request(self, endpoint: endpoint, params: params, handler: onJsonRetrieved)
    }
    
    final public class func upload(name: String, data: NSData, params: [String: AnyObject], onComplete: AnyObject? -> Void) {
        self.upload([name: data], params: params, onComplete: onComplete)
    }

    final public class func upload(data: [String: NSData], params: [String: AnyObject], onComplete: AnyObject? -> Void) {
        Api.shared(self.api()).upload(getRouter(), data: data, params: params) { objs in
            if objs?.count > 0 {
                onComplete(objs?[0])
            } else {
                onComplete(nil)
            }
        }
    }
    
    public class func doAction(endpoint: String, params: [String: AnyObject], onOneRetrieved: onPassengerRetrieved) {
        Api.shared(self.api()).request(getRouter(), endpoint: endpoint, params: params) { obj in
            if let obj: AnyObject = obj, one = self.parse(obj) as? Model {
                onOneRetrieved(one)
            } else {
                onOneRetrieved(nil)
            }
        }
    }

    public class func doAction(endpoint: String, params: [String: AnyObject], onManyRetrieved: onPassengersRetrieved) {
        Api.shared(self.api()).request(getRouter(), endpoint: endpoint, params: params) { objs in
            if let objs: AnyObject = objs, passengers = self.parse(objs) as? [Model] {
                onManyRetrieved(passengers)
            } else {
                onManyRetrieved(nil)
            }
        }
    }
    
    final public class func find(id: Int, onComplete: onPassengerRetrieved) {
        Api.shared(self.api()).find(self(["id": id])) { obj in
            if let record = obj as? Model {
                onComplete(record)
            } else {
                onComplete(nil)
            }
        }
    }

    final public class func create(params: [String: AnyObject], onComplete: onPassengerRetrieved) {
        Api.shared(self.api()).create(getRouter(), params: params) { obj in
            if let passenger = obj as? Model {
                onComplete(passenger)
            } else {
                onComplete(nil)
            }
        }
    }
    
    final public class func create(onComplete: onPassengerRetrieved) {
        self.create([String: AnyObject](), onComplete: onComplete)
    }
    
    final public class func list(onComplete: onPassengersRetrieved) {
        Api.shared(self.api()).list(self.getRouter()) { records in
            if let arr = records as? [Model] {
                onComplete(arr)
            } else {
                onComplete(nil)
            }
        }
    }
    
    final public class func search(params: [String: AnyObject], onComplete: onPassengersRetrieved) {
        Api.shared(self.api()).search(self.getRouter(), params: params) { records in
            if let arr = records as? [Model] {
                onComplete(arr)
            } else {
                onComplete(nil)
            }
        }
    }
    
    final public class func show(params: [String: AnyObject], onComplete: onPassengerRetrieved) {
        Api.shared(self.api()).search(self.getRouter(), params: params) { record in
            if let passenger = record as? Model {
                onComplete(passenger)
            } else {
                onComplete(nil)
            }
        }
    }
    
    private class func getRouter() -> Router {
        return PseudoRouter(type: self)
    }
}