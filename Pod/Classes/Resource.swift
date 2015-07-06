//
//  Resource.swift
//  Pods
//
//  Created by Kellan Cummings on 7/5/15.
//
//

import Foundation

public class Resource: NSObject, Router {

    public var id: Int = 0
    public var endpoint: String
    public var parent: Router?
    private var resources = [String: Router]()
    
    required public init(_ endpoint: String, parent: Router? = nil) {
        self.endpoint = endpoint
        self.parent = parent
        super.init()
    }
    
    public func construct(args: Json, node: String? = nil) -> AnyObject {
        if let node = node, json: AnyObject = args[node]  {
            return json
        }
        
        return args
    }
    
    public func getOwnershipHierarchy() -> [Router] {
        var components: [Router] = [self]
        var router: Router = self
        
        while let parent = router.parent {
            components.append(parent)
            router = parent
        }
        
        return components.reverse()
    }
    
    public func resource(endpoint: String) -> Resource {
        var resource = Resource(endpoint, parent: self)
        registerResource(resource)
        return resource
    }
    
    public func doAction(endpoint: String, params: [String: AnyObject], onComplete: AnyObject? -> Void) -> Resource {
        Api.shared.request(self, endpoint: endpoint, params: params, handler: onComplete)
        return self
    }
    
    public func upload(data: [String: NSData], params: Json, onComplete: AnyObject? -> Void) -> Resource {
        Api.shared.upload(self, data: data, params: params, onComplete: onComplete)
        return self
    }
    
    public func create(onComplete: AnyObject? -> Void) -> Resource {
        return self.create(Json(), onComplete: onComplete)
    }

    public func create(params: Json, onComplete: AnyObject? -> Void) -> Resource {
       Api.shared.create(self, params: params, onComplete: onComplete)
        return self
    }
    
    public func list(onComplete: AnyObject? -> Void) -> Resource {
        Api.shared.list(self, onComplete: onComplete)
        return self
    }
    
    public func search(params: [String: AnyObject], onComplete: AnyObject? -> Void) -> Resource {
        Api.shared.search(self, params: params, onComplete: onComplete)
        return self
    }
    
    private func registerResource(resource: Resource) -> Resource {
        resources[resource.endpoint] = resource
        return self
    }
}