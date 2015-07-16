//
//  Api.swift
//  Pods
//
//  Created by Kellan Cummings on 6/10/15.
//
//

import Foundation

private var api = [String: Api]()

internal let SHOW_VERSION_IN_PATH: UInt64 = 1
internal let USE_ACCEPT_HEADERS: UInt64 = 2
internal let USE_FILE_EXTENSIONS: UInt64 = 4

/**
    API class; instantiated when calling its class `shared` with or without a namespace; built from your api.plist and endpoints.plist files.

*/
public class Api: NSObject {
    
    private var url: NSURL?
    private var version: String = ""
    private var namespace: String = ""
    private var flags: UInt64 = 0
    private var consumerKey: String
    private var authorization = [AuthorizationType: AuthorizationService]()

    internal var endpoints = [String: Endpoint]()

    /**
        Consumer key.
    */
    public var key: String {
        return consumerKey
    }

    /**
        Returns a string description of the object for console output
    */
    override public var description: String {
        var str = ""
        
        for (key, endpoint) in endpoints {
            var description = endpoint.getDescription()
            str += "\n\(description)"
        }
        
        return str
    }
    
    internal var basepath: String? {
        return url?.absoluteString
    }

    internal init(_ apiName: String) {
        let apiFilename = "\(apiName)api"
        let endpointsFilename = "\(apiName)endpoints"

        if let apiPath = NSBundle.mainBundle().pathForResource(apiFilename, ofType: "plist") {
            if let data = NSDictionary(contentsOfFile: apiPath) {
                //println("API Config \(data)")
                
                if let consumerKey = data["consumer_key"] as? String {
                    self.consumerKey = consumerKey
                } else {
                    fatalError("Must provide 'consumer_key' field in api.plist.")
                }
                
                if let ns = data["namespace"] as? String {
                    namespace = ns
                }
            
                if let urlString = data["url"] as? String {
                    self.url = NSURL(string: urlString)
                }

                if let auth = data["authorization"] as? [String: AnyObject] {
                    for (key, value) in auth {
                        if let hash = value as? [String: AnyObject], key = AuthorizationType(rawValue: key) {
                            //println("\(key) \(value)")
                            switch key {
                                case .OAuth1:
                                    authorization[key] = OAuth1(key: self.consumerKey, params: hash)
                                case .OAuth2:
                                    authorization[key] = OAuth2(key: self.consumerKey, params: hash)
                                default:
                                    authorization[key] = BasicAuth(key: self.consumerKey, params: hash)
                            }
                        }
                    }
                }
                
                if let version = data["version"] as? String {
                    self.version = version
                }
                
                if let options = data["options"] as? NSDictionary {
                    for (k, v) in options {
                        if let key = k as? String, let option = v as? Bool {
                            switch key {
                                case "show_version_in_path":
                                    self.flags |= (option ? SHOW_VERSION_IN_PATH : 0)
                                case "use_file_extensions":
                                    self.flags |= (option ? USE_FILE_EXTENSIONS : 0)
                                case "use_accept_headers":
                                    self.flags |= (option ? USE_ACCEPT_HEADERS : 0)
                                default:
                                    fatalError("No option called '\(key)'.")
                            }
                        }
                    }
                }
            } else {
                fatalError("Could not parse contents of api.plist file. Please check file. It may be corrupt.")
            }
        } else {
            fatalError("api.plist file not found in main directory.")
        }
        
        if let endpointsPath = NSBundle.mainBundle().pathForResource(endpointsFilename, ofType: "plist") {
            if let data = NSDictionary(contentsOfFile: endpointsPath) {
                //println("Endpoints \(data)")
                for (key, value) in data {
                    //println("Setting Endpoint: \(key)")
                    if let endpoint = value as? [String: AnyObject], let type = key as? String {
                        self.endpoints[type] = Endpoint(type: type, values: endpoint)
                    }
                }
            } else {
                fatalError("Could not parse contents of endpoints.plist file. Please check file. It may be corrupt.")
            }
        } else {
            fatalError("endpoints.plist file not found in main directory.")
        }
    }
    
    /**
        Retrieve a shared singleton `Api` instance. The name parameter should correspond to the name of you 'endpoints.plist' and 'api.plist' files. For instance, if you're using the Twitter API, name your property lists 'twitter.api.plist' and 'twitter.endpoints.plist', respectively, and pass in "twitter" as the `name` parameter when accessing your Api.
    
        If `name` is left blank it will look for the generic files 'endpoints.plist' and 'api.plist'.
    
        :param:     name    the name of the Api
    
        :returns:       an `Api` instance
    
    */
    public class func shared(_ name: String? = nil) -> Api {
        if let name = name {
            if let singleton = api[name] {
                return singleton
            } else {
                api[name] = Api("\(name).")
                return api[name]!
            }
        } else {
            if let singleton = api[""] {
                return singleton
            } else {
                api[""] = Api("")
                return api[""]!
            }
        }
    }

    /**
        Retrieves the named `AuthorizationService`
    
        :param: method  an `AuthorizationType`. Currently restricted to `.Oauth1` and `.BasicAuth`.
    
        :returns:   an AuthorizationService
    */
    public func getAuthorizationService(method: AuthorizationType) -> AuthorizationService? {
        return authorization[method]
    }

    //Get all from collection
    internal func list(router: Router, onComplete: AnyObject? -> Void) -> Api {
        return request(router, route: "list", params: [String: AnyObject](), handler: onComplete)
    }

    //Get all in acollection that meet parameter
    internal func search(router: Router, params: [String: AnyObject], onComplete: AnyObject? -> Void) -> Api {
        return request(router, route: "search", params: params, handler: onComplete)
    }

    //Get One Element In Collection
    internal func find(router: Router, onComplete: (AnyObject?) -> ()) -> Api {
        return request(router, route: "find", params: [String: AnyObject](), handler: onComplete)
    }

    //Get One Element in Collection with Parameters
    internal func show(router: Router, params: [String: AnyObject], onComplete: (AnyObject?) -> ()) -> Api {
        return request(router, route: "show", params: [String: AnyObject](), handler: onComplete)
    }

    //Create One in Collection
    internal func create(router: Router, params: [String: AnyObject], onComplete: AnyObject? -> Void) -> Api {
        return request(router, route: "create", params: params, handler: onComplete)
    }
    
    //Destroy One Element
    internal func destroy(passenger: Model, onComplete:  AnyObject? -> Void) -> Api {
        return request(passenger, route: "destroy", params: ["id": passenger.id], handler: onComplete)
    }
    
    //Save Element
    internal func save(router: Router, params: [String: AnyObject], onComplete: AnyObject? -> Void) -> Api {
        return request(router, route: "save", params: params, handler: onComplete)
    }
    
    internal func upload(router: Router, data: [String: NSData], params: [String:AnyObject], onComplete: AnyObject? -> Void) -> Api {
        if let request = getMultipartRequest(router, data: data, params: params, handler: onComplete) {
            Http.start(request)
        } else {
            onComplete(nil)
        }
        
        return self
    }
    
    internal func request(router: Router, route: String, params: [String: AnyObject], handler: AnyObject? -> Void) -> Api {
        
        if let request = getRequest(router, route: route, params: params, handler: handler) {
            Http.start(request)
        } else {
            handler(nil)
        }
        
        return self
    }
    
    private func getRequest(router: Router, route: String, var params: [String: AnyObject], handler: (AnyObject?) -> ()) -> HttpRequest? {

        if let route = getRoute(router, route: route) {
            if let url = getUrl(router, route: route, params: &params) {
                var request: HttpRequest
                
                if route.method == .Delete || route.action == "list" {
                    request = HttpRequest(
                        URL: url,
                        method: route.method ?? HttpMethod.Get,
                        handler: prepareHttpRequestHandler(router, route: route, onComplete: handler)
                    )
                } else {
                    request = HttpRequest(
                        URL: url,
                        method: route.method ?? HttpMethod.Get,
                        params: params,
                        handler: prepareHttpRequestHandler(router, route: route, onComplete: handler)
                    )
                }
                
                if let rawauth = route.auth, auth = AuthorizationType(rawValue: rawauth), service = getAuthorizationService(auth) {
                    request.authenticate(service)
                }
                
                return request
            } else {
                fatalError("No Url for \(router).\(route)")
            }
        } else {
            fatalError("No Route for \(router.endpoint).\(route)")
        }
        
        return nil
    }

    private func getMultipartRequest(router: Router, var data: [String: NSData], var params: [String: AnyObject], handler: (AnyObject?) -> ()) -> HttpMultipartRequest? {
        
        if let route = getRoute(router, route: "upload"), let url = getUrl(router, route: route, params: &params) {
            var request = HttpMultipartRequest(
                URL: url,
                data: data,
                params: params,
                handler: prepareHttpRequestHandler(router, route: route, onComplete: handler)
            )
            
            if let rawauth = route.auth, auth = AuthorizationType(rawValue: rawauth), service = getAuthorizationService(auth) {
                request.authenticate(service)
            }
            
            return request
        } else {
            fatalError("No Endpoint for \(router).upload")
        }
        
        return nil
    }

    private func getRoute(router: Router, route: String) -> Route? {
        if let endpoint = getEndpoint(router) {
            if let route = endpoint.getRoute(route) {
                return route
            } else {
                println("No Route.")
            }
        } else {
            println("No Endpoint.")
        }
    
        return nil
    }
    
    private func getUrl(router: Router, route: Route, inout params: [String:AnyObject]) -> NSURL? {
        let versionpath: String = (self.flags & SHOW_VERSION_IN_PATH > 0) ? "/\(version)" : ""
 
        let routepath = route.applyArguments(router)
        
        //println("ROUTE PATH: \(routepath)")
        
        var fileExtension = ""

        if let mediaType = route.contentType.fileExtension {
            fileExtension += ".\(mediaType)"
        }
        
        let extensionpath: String = (self.flags & USE_FILE_EXTENSIONS > 0) ? fileExtension  : ""
        let urlpath: String = basepath ?? ""
        
        return NSURL(string: "\(urlpath)\(versionpath)\(routepath)\(extensionpath)")
    }
    
    private func prepareHttpRequestHandler(router: Router, route: Route, onComplete: AnyObject? -> Void) -> NSData! -> Void {
        switch route.action {
            case "create", "list", "search", "find", "save", "destroy":
                return { data in
                    if data != nil {
                        if let json: AnyObject = data.parseJson() {
                            onComplete(router.construct(json, node: route.node))
                        } else {
                            onComplete(nil)
                        }
                    } else {
                        onComplete(nil)
                    }
                }
            default: // includes save, upload, and destroy
                return { data in
                    if data != nil {
                        onComplete(data.parseJson())
                    } else {
                        onComplete(nil)
                    }
                }
        }
    }
    
    private func getEndpoint(var router: Router?) -> Endpoint? {
        var endpoints = self.endpoints
        var lastEndpoint: Endpoint? = nil

        //println("Endpoints: \(endpoints)")
        
        var components: [Router] = router?.getOwnershipHierarchy() ?? [Router]()
        
        //println("Endpoints:")
        for component in components {
            //println("\t\(component.dynamicType) : \(component.endpoint)")
            if let endpoint = endpoints[component.endpoint] {
                lastEndpoint = endpoint
                endpoints = lastEndpoint!.endpoints
                //println("Next Endpoints \(endpoints)")
            } else if let endpoint = endpoints[component.endpoint.pluralize()] {
                lastEndpoint = endpoint
                endpoints = lastEndpoint!.endpoints
            } else {
                println("No Endpoint for \(component.endpoint) : \(endpoints)")
            }
        }
        
        return lastEndpoint
    }
}

