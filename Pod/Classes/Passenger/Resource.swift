//
//  Resource.swift
//  Pods
//
//  Created by Kellan Cummings on 7/5/15.
//
//

import Foundation

public class Resource: Passenger {

    private var _endpoint: String = ""
    private var _parent: Passenger?
        
    override public var endpoint: String {
        return _endpoint
    }

    override public var parent: Passenger? {
        get {
            return _parent
        }
        set(newParent) {
            _parent = newParent
        }
    }

    private var resources = [String: Router]()
    
    public init(_ endpoint: String, parent: Passenger? = nil) {
        self._endpoint = endpoint
        self._parent = parent
        super.init(Json())
    }

    required public init(_ properties: Json) {
        println("Resource should not be instantiated.")
        super.init(Json())
    }
    
    override public func construct(args: AnyObject, node: String? = nil) -> AnyObject {

        if let node = node, json: AnyObject = args[node] {
            return json
        }
        
        return args
    }
    
    public func resource(endpoint: String) -> Resource {
        var resource = Resource(endpoint, parent: self)
        registerResource(resource)
        return resource
    }
    
    public func doAction(endpoint: String, params: [String: AnyObject], onComplete: AnyObject? -> Void) {
        Api.shared(self.dynamicType.api()).request(self, endpoint: endpoint, params: params, handler: onComplete)
    }
    
    public func upload(data: [String: NSData], params: Json, onComplete: AnyObject? -> Void) {
        Api.shared(self.dynamicType.api()).upload(self, data: data, params: params, onComplete: onComplete)
    }

    public func create(onComplete: AnyObject? -> Void) {
        create(Json(), onComplete: onComplete)
    }

    public func create(params: Json, onComplete: AnyObject? -> Void) {
       Api.shared(self.dynamicType.api()).create(self, params: params, onComplete: onComplete)
    }
    
    public func list(onComplete: AnyObject? -> Void) {
        Api.shared(self.dynamicType.api()).list(self, onComplete: onComplete)
    }
    
    public func search(params: [String: AnyObject], onComplete: AnyObject? -> Void) {
        Api.shared(self.dynamicType.api()).search(self, params: params, onComplete: onComplete)
    }
    
    private func registerResource(resource: Resource) {
        resources[resource.endpoint] = resource
    }
}