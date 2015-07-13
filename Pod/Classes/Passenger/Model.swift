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
        Api.shared.save(self, params: serialize() as? Json ?? Json(), onComplete: onComplete)
    }
    
    public func create(onComplete: onPassengerRetrieved) {
        Api.shared.create(self, params: serialize() as? Json ?? Json()) { [unowned self] obj in
            if let passenger = obj as? Model {
                onComplete(passenger)
            } else {
                onComplete(nil)
            }
        }
    }
    
    public func destroy(onComplete: AnyObject? -> Void) {
        Api.shared.destroy(self, onComplete: onComplete)
    }
        
    public class func doAction(endpoint: String, params: [String: AnyObject], onOneRetrieved: onPassengerRetrieved) {
        Api.shared.request(getRouter(params: params), endpoint: endpoint, params: params) { obj in
            if let obj: AnyObject = obj, one = self.parse(obj) as? Model {
                onOneRetrieved(one)
            } else {
                onOneRetrieved(nil)
            }
        }
    }

    public class func doAction(endpoint: String, params: [String: AnyObject], onManyRetrieved: onPassengersRetrieved) {
        Api.shared.request(getRouter(params: params), endpoint: endpoint, params: params) { objs in
            if let objs: AnyObject = objs, passengers = self.parse(objs) as? [Model] {
                onManyRetrieved(passengers)
            } else {
                onManyRetrieved(nil)
            }
        }
    }
    
    final public class func find(id: Int, onComplete: onPassengerRetrieved) {
        Api.shared.find(self(["id": id])) { obj in
            if let record = obj as? Model {
                onComplete(record)
            } else {
                onComplete(nil)
            }
        }
    }

    final public class func create(params: [String: AnyObject], onComplete: onPassengerRetrieved) {
        Api.shared.create(getRouter(params: params), params: params) { obj in
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
        Api.shared.list(self.getRouter()) { records in
            if let arr = records as? [Model] {
                onComplete(arr)
            } else {
                onComplete(nil)
            }
        }
    }
    
    final public class func search(params: [String: AnyObject], onComplete: onPassengersRetrieved) {
        Api.shared.search(self.getRouter(), params: params) { records in
            if let arr = records as? [Model] {
                onComplete(arr)
            } else {
                onComplete(nil)
            }
        }
    }
    
    final public class func show(params: [String: AnyObject], onComplete: onPassengerRetrieved) {
        Api.shared.search(self.getRouter(), params: params) { record in
            if let passenger = record as? Model {
                onComplete(passenger)
            } else {
                onComplete(nil)
            }
        }
    }
    
    private class func getRouter(params: Json = Json()) -> Router {
        return PseudoRouter(type: self)
    }
}