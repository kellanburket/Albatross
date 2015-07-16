//
//  Model.swift
//  Pods
//
//  Created by Kellan Cummings on 7/12/15.
//
//

import Foundation

/**
    Represents types that can be accessed through an Api. Class should be used as a base class for models unique to an Api. Each model should match an endpoint in your endpoints.plist file.
*/
public class Model: ApiObject {
    
    /**
        The identify value of the model
    */
    public var id: Int = 0

    /**
        Serializes a model for database consumption and calls the endpoint's "save" route (an HTTP-Put request, sending the serialized model as the request body).
        
        :param: onComplete  an asynchronous callback function that takes a block of parsed data (usually an array or dictionary) as its only argument; a nil response indicates that the transaction was unsuccessful
    */
    final public func save(onComplete: AnyObject? -> Void) {
        Api.shared(self.dynamicType.api()).save(self, params: serialize() as? [String: AnyObject] ?? [String: AnyObject](), onComplete: onComplete)
    }

    /**
        Create a new model by asynchronously calling the endpoint's "create" route (an HTTP-Post request, sending the serialized object as the request body).
        
        :param: onModelRetrieved an aysnchronous callback function called that takes an optional `Model` instance as its argument
    */
    public func create(onComplete: onModelRetrieved) {
        Api.shared(self.dynamicType.api()).create(self, params: serialize() as? [String: AnyObject] ?? [String: AnyObject]()) { [unowned self] obj in
            if let passenger = obj as? Model {
                passenger.parent = self
                onComplete(passenger)
            } else {
                onComplete(nil)
            }
        }
    }

    /**
        Delete a model by calling the endpoint's "destroy" route (an HTTP-Delete request)
        
        :param: onComplete  an asynchronous callback function that takes a block of parsed data (usually an array or dictionary) as its only argument; a nil response indicates that the transaction was unsuccessful
    */
    public func destroy(onComplete: AnyObject? -> Void) {
        Api.shared(self.dynamicType.api()).destroy(self, onComplete: onComplete)
    }
    
    /**
        Do asynchronous model action with custom route; a nil response indicates that the transaction was unsuccessful

        :param: route   a String representation of the route; appears as a route in endpoints.plist under the desired endpoint
        :param: params  a dictionary of parameters to pass to the server
        :param: onComplete an asynchronous callback function that takes a block of parsed data (usually an array or dictionary) as its only argument
    */
    public func doAction(route: String, params: [String: AnyObject], onComplete: AnyObject? -> Void) {
        Api.shared(self.dynamicType.api()).request(self, route: route, params: params, handler: onComplete)
    }
    

    /**
        Asynchronously uploads a single resource by calling an endpoint's "upload" route (an HTTP-Post request with content type 'Multipart-FormData')
    
        :param: name    the name of the resource
        :param: data    resource data
        :param: params  any additional parameters to post to the server
        :param: onComplete  an asynchronous callback function that takes a block of parsed data (usually an array or dictionary) as its only argument; a nil response indicates that the transaction was unsuccessful
    
    */
    final public class func upload(name: String, data: NSData, params: [String: AnyObject], onComplete: AnyObject? -> Void) {
        self.upload([name: data], params: params, onComplete: onComplete)
    }

    /**
        Asynchronously uploads multiple resources by calling an endpoint's "upload" route (an HTTP-Post request with content type 'Multipart-FormData')
        
        :param: data    a dictionary with resource filenames as its keys and resource data as its values
        :param: params  any additional parameters to post to the server
        :param: onComplete  an asynchronous callback function that takes a block of parsed data (usually an array or dictionary) as its only argument; a nil response indicates that the transaction was unsuccessful
        
    */
    final public class func upload(data: [String: NSData], params: [String: AnyObject], onComplete: AnyObject? -> Void) {
        self.upload(getRouter(), data: data, params: params, onComplete: onComplete)
    }

    final internal class func upload(router: Router, data: [String: NSData], params: [String: AnyObject], onComplete: AnyObject? -> Void) {
        Api.shared(self.api()).upload(router, data: data, params: params) { objs in
            if objs?.count > 0 {
                onComplete(objs?[0])
            } else {
                onComplete(nil)
            }
        }
    }
   
    /**
        Do model action with custom route; asynchronously returns a model instance from the server
        
        :param: route   a String representation of the route; appears as a route in endpoints.plist under the current endpoint
        :param: params  a dictionary of parameters to pass to the server
        :param: onOneRetrieved an asynchronous callback function that takes an optional `Model` instance as its only argument
    */
    final public class func doAction(route: String, params: [String: AnyObject], onOneRetrieved: onModelRetrieved) {
        self.doAction(getRouter(), route: route, params: params, onOneRetrieved: onOneRetrieved)
    }
    
    final internal class func doAction(router: Router, route: String, params: [String: AnyObject], onOneRetrieved: onModelRetrieved) {
        Api.shared(self.api()).request(router, route: route, params: params) { obj in
            if let obj: AnyObject = obj, one = self.parse(obj) as? Model {
                onOneRetrieved(one)
            } else {
                onOneRetrieved(nil)
            }
        }
    }

    /**
        Do model action with custom route that asynchronously returns an array of model instances from the server
        
        :param: route   a String representation of the route; appears as a route in endpoints.plist under the desired endpoint
        :param: params  a dictionary of parameters to pass to the server
        :param: onManyRetrieved an asynchronous callback function that takes an array of `Model` instances as its only argument
    */
    final public class func doAction(route: String, params: [String: AnyObject], onManyRetrieved: onModelsRetrieved) {
        self.doAction(getRouter(), route: route, params: params, onManyRetrieved: onManyRetrieved)
    }
    
    final internal class func doAction(router: Router, route: String, params: [String: AnyObject], onManyRetrieved: onModelsRetrieved) {
        Api.shared(self.api()).request(router, route: route, params: params) { objs in
            if let objs: AnyObject = objs, passengers = self.parse(objs) as? [Model] {
                onManyRetrieved(passengers)
            } else {
                onManyRetrieved(nil)
            }
        }
    }

    /**
        Find a model with a given id by calling the endpoint's "find" route (an HTTP-Get request); note that `find` only works for routes with parameters embedded in their urls; e.g.: 'user/posts/:id'; asynchronously returns the desired model or nil if none is found
        
        :param: id  the endpoint id
        :param: onOneRetrieved an asynchronous callback function that takes an optional `Model` instance as its only argument
    */
    final public class func find(id: Int, onComplete: onModelRetrieved) {
        self.find(self(["id": id]), id: id, onComplete: onComplete)
    }

    final internal class func find(router: Router, id: Int, onComplete: onModelRetrieved) {
        Api.shared(self.api()).find(router) { obj in
            if let record = obj as? Model {
                onComplete(record)
            } else {
                onComplete(nil)
            }
        }
    }

    /**
        Create a new model by calling the endpoint's "create" route (an HTTP-Post request with no body); asynchronously returns the new model or nil if creation fails
        
        :param: onModelRetrieved a n asynchronous callback function that takes an optional `Model` instance as its argument
    */
    final public class func create(onComplete: onModelRetrieved) {
        self.create([String: AnyObject](), onComplete: onComplete)
    }

    /**
        Create a new, unparented model by calling the endpoint's "create" route (an HTTP-Post request with the given parameters as the Post-body); asynchronously returns the new model or nil if creation fails
        
        :param: params  parameters to pass to the server
        :param: onModelRetrieved an aysnchronous callback function that takes an optional `Model` instance as its argument
    */
    final public class func create(params: [String: AnyObject], onComplete: onModelRetrieved) {
        self.create(getRouter(), params: params, onComplete: onComplete)
    }
    
    final internal class func create(router: Router, params: [String: AnyObject], onComplete: onModelRetrieved) {
        Api.shared(self.api()).create(router, params: params) { obj in
            if let passenger = obj as? Model {

                onComplete(passenger)
            } else {
                onComplete(nil)
            }
        }
    }

    
    /**
        List all models by calling the endpoint's "list" route (an HTTP-Get request with no attached query); asynchronously returns the an array of models or nil if creation fails
        
        :param: onModelsRetrieved an asynchronous callback function that takes an optional array of `Model` instances as its argument
    */
    final public class func list(onComplete: onModelsRetrieved) {
        self.list(getRouter(), onComplete: onComplete)
    }

    final internal class func list(router: Router, onComplete: onModelsRetrieved) {
        Api.shared(self.api()).list(router) { records in
            if let arr = records as? [Model] {
                onComplete(arr)
            } else {
                onComplete(nil)
            }
        }
    }

    /**
        List a selection of models by calling the selected endpoint's "search" route (an HTTP-Get request with optional query parameters); asynchronously returns the an array of models or nil if creation fails
        
        :param: params  parameters to filter search results
        :param: onModelsRetrieved an asynchronous callback function that takes an optional array of `Model` instances as its argument
    */
    final public class func search(params: [String: AnyObject], onComplete: onModelsRetrieved) {
        self.search(getRouter(), params: params, onComplete: onComplete)
    }
    
    final internal class func search(router: Router, params: [String: AnyObject], onComplete: onModelsRetrieved) {
        Api.shared(self.api()).search(router, params: params) { records in
            if let arr = records as? [Model] {
                onComplete(arr)
            } else {
                onComplete(nil)
            }
        }
    }

    /**
        Find a model matching the given search criteria by calling the endpoint's "show" route (an HTTP-Get request); asynchronously returns the desired model or nil if the request fails
        
        :param: onOneRetrieved an asynchronous callback function that takes an optional `Model` instance as its first argument
    */
    final public class func show(params: [String: AnyObject], onComplete: onModelRetrieved) {
        self.show(getRouter(), params: params, onComplete: onComplete)
    }

    final internal class func show(router: Router, params: [String: AnyObject], onComplete: onModelRetrieved) {
        Api.shared(self.api()).search(router, params: params) { record in
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