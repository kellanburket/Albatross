//
//  Resource.swift
//  Pods
//
//  Created by Kellan Cummings on 7/5/15.
//
//

import Foundation

/**
    Represents a resource without a distinct model type; useful for creating endpoints that don't link to or produce defined models;

    Resources are typically used without subclassing, but if you are using named `Api` instances, a `Resource` type that overrides the `api` func should be subclassed for each named Api.

*/
public class Resource: ApiObject {

    private var _endpoint: String = ""
    private var _parent: ApiObject?
    
    /**
        A custom endpoint; set at initialization
    */
    override public var endpoint: String {
        return _endpoint
    }

    /**
        Resource parent
    */
    override public var parent: ApiObject? {
        get {
            return _parent
        }
        set(newParent) {
            _parent = newParent
        }
    }

    private var resources = [String: Router]()
    
    /**
        Initialize a `Resource` with an endpoint and optional parent
    
        If your endpoints.plist contains a custom endpoint called 'Upload', you can create a resource by initializing like so: 
    
            var resource = Resource("Upload")
    
        :param: endpoint    A `String` representation of the desired endpoint
        :param: parent  A `Passenger` object that owns this Resource; useful for creating nested endpoints
    */
    required public init(_ endpoint: String, parent: ApiObject? = nil) {
        self._endpoint = endpoint
        self._parent = parent
    }

    /**
        By definition, a `Resource` should never be initialized with a set of properties; if you need this functionality you should be using a `Model` instead
    */
    required public init(_ properties: [String: AnyObject]) {
        fatalError("Resource should not be instantiated.")
    }
    
    override internal func construct(args: AnyObject, node: String? = nil) -> AnyObject {

        if let node = node, json: AnyObject = args[node] {
            return json
        }
        
        return args
    }
    
    /**
        Create a new `Resource` owned by this `Resource`; useful for nesting custom `Resource` endpoints
    
        :param: endpoint    A `String` representation of the desired endpoint

        :returns: Self, for chaining
    */
    public func resource(endpoint: String) -> Self {
        var resource = self.dynamicType(endpoint, parent: self)
        registerResource(resource)
        return resource
    }

    /**
        Do custom action with custom route; asynchronously returns raw data from the server
        
        :param: route   a String representation of the route; appears as a route in endpoints.plist under the current endpoint
        :param: params  a dictionary of parameters to pass to the server
        :param: onComplete  an asynchronous callback function that takes a block of raw data (usually an array or dictionary) as its only argument; a nil response indicates that the transaction was unsuccessful
    */
    public func doAction(route: String, params: [String: AnyObject], onComplete: AnyObject? -> Void) {
        Api.shared(self.dynamicType.api()).request(self, route: route, params: params, handler: onComplete)
    }

    /**
        Asynchronously uploads multiple resources by calling a resource's "upload" route (an HTTP-Post request with content type 'Multipart-FormData')
        
        :param: data    a dictionary with resource filenames as its keys and resource data as its values
        :param: params  any additional parameters to post to the server
        :param: onComplete  an asynchronous callback function that takes a block of raw data (usually an array or dictionary) as its only argument; a nil response indicates that the transaction was unsuccessful
    */
    public func upload(data: [String: NSData], params: [String: AnyObject], onComplete: AnyObject? -> Void) {
        Api.shared(self.dynamicType.api()).upload(self, data: data, params: params, onComplete: onComplete)
    }

    /**
        Calls the endpoint's "create" route (an HTTP-Post request with no body)

        :param: onComplete  an asynchronous callback function that takes a block of raw data (usually an array or dictionary) as its only argument; a nil response indicates that the transaction was unsuccessful
    */
    public func create(onComplete: AnyObject? -> Void) {
        create([String: AnyObject](), onComplete: onComplete)
    }

    /**
        Calls the endpoint's "create" route (an HTTP-Post request with parameters as the Post body)

        :param: onComplete  an asynchronous callback function that takes a block of raw data (usually an array or dictionary) as its only argument; a nil response indicates that the transaction was unsuccessful
    */
    public func create(params: [String: AnyObject], onComplete: AnyObject? -> Void) {
       Api.shared(self.dynamicType.api()).create(self, params: params, onComplete: onComplete)
    }
    

    /**
        Calls the endpoint's "list" route (an HTTP-Get request with no Post body)

        :param: onComplete  an asynchronous callback function that takes a block of raw data (usually an array or dictionary) as its only argument; a nil response indicates that the transaction was unsuccessful
    */
    public func list(onComplete: AnyObject? -> Void) {
        Api.shared(self.dynamicType.api()).list(self, onComplete: onComplete)
    }

    /**
        Calls the endpoint's "search" route (an HTTP-Get request with parameters as the Post body)

        :param: onComplete  an asynchronous callback function that takes a block of raw data (usually an array or dictionary) as its only argument; a nil response indicates that the transaction was unsuccessful
    */
    public func search(params: [String: AnyObject], onComplete: AnyObject? -> Void) {
        Api.shared(self.dynamicType.api()).search(self, params: params, onComplete: onComplete)
    }
    
    private func registerResource(resource: Resource) {
        resources[resource.endpoint] = resource
    }
}