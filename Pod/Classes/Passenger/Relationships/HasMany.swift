//
//  HasMany.swift
//  Pods
//
//  Created by Kellan Cummings on 6/30/15.
//
//

import Foundation

/**
    a OneToManyRelationship wrapper for Models. Use in place of an array of `Model`s when setting `ApiObject` properties.
*/
public class HasMany<T: Model>: OneToManyRelationship<T>, SequenceType {
 
    /**
        Initializer
    */
    override public init() {
        super.init()
    }
    
    /**
        List all `T`s by calling the base endpoint's "list" route (an HTTP-Get request with no attached query)
    
        asynchronously returns the an array of `T`s (and registers them with the collection), or nil if creation fails
        
        :param: onComplete an asynchronous callback function that takes an optional array of `T` instances as its argument
    */
    public func list(onComplete: [T]? -> ()) {
         T.list(self) { records in
            if let passengers = records as? [T] {
                for passenger in passengers {
                    self.registerPassenger(passenger)
                }
                onComplete(passengers)
            } else {
                onComplete(nil)
            }
        }
    }

    /**
        Create a new `T` by calling the base endpoint's "create" route (an HTTP-Post request with the given parameters as the Post-body)
    
        asynchronously returns the new `T` (and registers it with the collection) or nil if creation fails
        
        :param: params  parameters to pass to the server
        :param: onComplete an aysnchronous callback function that takes an optional `T` instance as its argument
    */
    public func create(params: [String: AnyObject], onComplete: T? -> Void) {
        
        T.create(self, params: params) { record in
            if let passenger = record as? T {
                self.registerPassenger(passenger)
                onComplete(passenger)
            } else {
                onComplete(nil)
            }
        }
    }

    /**
        Find a `T` with a given id by calling the base endpoint's "find" route (an HTTP-Get request); note that `find` only works for routes with parameters embedded in their urls; e.g.: 'user/posts/:id'
    
        asynchronously returns the desired `T` (and registers it with the collection) or nil if none is found
        
        :param: id  the endpoint id
        :param: onComplete an asynchronous callback function that takes an optional `T` instance as its only argument
    */
    public func find(id: Int, onComplete: T? -> Void) {
        let passenger = T(["id": id])
        registerPassenger(passenger)
        if let router = passenger as? Router {
            T.find(router, id: passenger.id) { record in
                if let passenger = record as? T {
                    self.registerPassenger(passenger)
                    onComplete(passenger)
                } else {
                    onComplete(nil)
                }
            }
        }
    }

    /**
        Asynchronously uploads multiple resources by calling the base endpoint's "upload" route (an HTTP-Post request with content type 'Multipart-FormData')
        
        :param: data    a dictionary with resource filenames as its keys and resource data as its values
        :param: params  any additional parameters to post to the server
        :param: onComplete  an asynchronous callback function that takes a block of parsed data (usually an array or dictionary) as its only argument; a nil response indicates that the transaction was unsuccessful
        
    */
    public func upload(data: [String: NSData], params: [String: AnyObject], onComplete: AnyObject? -> Void) {
        T.upload(self, data: data, params: params, onComplete: onComplete)
    }

    /**
        Generator used to iterate over `passengers` array
    */
    public func generate() -> GeneratorOf<T> {
        var index = 0
        return GeneratorOf {
            if index < self.passengers.count {
                return self.passengers[index++]
            }
            
            return nil
        }
    }
}