//
//  Api.swift
//  Pods
//
//  Created by Kellan Cummings on 6/10/15.
//
//

import Foundation
import Reflektor

private var api: Api?
internal let SHOW_VERSION_IN_PATH: UInt64 = 1
internal let USE_ACCEPT_HEADERS: UInt64 = 2
internal let USE_FILE_EXTENSIONS: UInt64 = 4

public class Api: NSObject {
    
    private var url: NSURL?
    private var version: String = ""
    public var namespace: String = ""
    private var flags: UInt64 = 0
    private var consumerKey: String
    
    private var authorization = [AuthorizationType: AuthorizationService]()
    public var endpoints = [String: Endpoint]()
    
    public var key: String {
        return consumerKey
    }
    
    internal override init() {
        //println("Initializing API")
        
        if let apiPath = NSBundle.mainBundle().pathForResource("api", ofType: "plist") {
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
                        //if let authService = ClassReflektor.create(key as! String) as? AuthorizationService {   authorization["\(key)"] = authService }
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
        
        if let endpointsPath = NSBundle.mainBundle().pathForResource("endpoints", ofType: "plist") {
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
    
    public class var shared: Api {
        if let singleton = api {
            return singleton
        } else {
            api = Api()
            return api!
        }
    }
    
    //Get all from collection
    public func list(router: Router, onComplete: AnyObject? -> Void) -> Api {
        return request(router, endpoint: "list", params: [String: AnyObject](), handler: onComplete)
    }

    //Get all in acollection that meet parameter
    public func search(router: Router, params: [String: AnyObject], onComplete: AnyObject? -> Void) -> Api {
        return request(router, endpoint: "search", params: params, handler: onComplete)
    }

    //Get One In Collection
    public func find(router: Router, onComplete: (AnyObject?) -> ()) -> Api {
        return request(router, endpoint: "find", params: [String: AnyObject](), handler: onComplete)
    }
    
    //Create One in Collection
    public func create(router: Router, params: [String: AnyObject], onComplete: AnyObject? -> Void) -> Api {
        return request(router, endpoint: "create", params: params, handler: onComplete)
    }
    
    //Destroy One Element
    public func destroy(passenger: Passenger, onComplete:  AnyObject? -> Void) -> Api {
        return request(passenger, endpoint: "destroy", params: ["id": passenger.id], handler: onComplete)
    }
    
    //Save Element
    public func save(router: Router, params: [String: AnyObject], onComplete: AnyObject? -> Void) -> Api {
        return request(router, endpoint: "save", params: params, handler: onComplete)
    }
    
    public func upload(router: Router, data: [String: NSData], params: [String:AnyObject], onComplete: AnyObject? -> Void) -> Api {
        if let request = getMultipartRequest(router, data: data, params: params, handler: onComplete) {
            Http.start(request)
        } else {
            onComplete(nil)
        }
        
        return self
    }
    
    public func request(router: Router, endpoint: String, params: [String: AnyObject], handler: AnyObject? -> Void) -> Api {
        
        if let request = getRequest(router, action: endpoint, params: params, handler: handler) {
            Http.start(request)
        } else {
            handler(nil)
        }
        
        return self
    }
    
    public func getValue<T>(key: String, onComplete: T? -> Void) {
        var handler: NSData -> Void = { data in
            if let json = data.parseJson(), value = json[key] as? T {
                onComplete(value)
            } else {
                onComplete(nil)
            }
        }
    }

    
    public var basepath: String? {
        return url?.absoluteString
    }
    
    public func getAuthorizationService(method: AuthorizationType) -> AuthorizationService? {
        return authorization[method]
    }

    private func getRequest(router: Router, action: String, var params: [String: AnyObject], handler: (AnyObject?) -> ()) -> HttpRequest? {

        if let route = getRoute(router, action: action), let url = getUrl(router, route: route, params: &params) {
            
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
            
            if let rawauth = route.auth, auth = AuthorizationType(rawValue: rawauth), service = Api.shared.getAuthorizationService(auth) {
                request.authorize(service)
            }
            
            return request
        } else {
            fatalError("No Endpoint for \(router).\(action)")
        }
        
        return nil
    }

    private func getMultipartRequest(router: Router, var data: [String: NSData], var params: [String: AnyObject], handler: (AnyObject?) -> ()) -> HttpMultipartRequest? {
        
        if let route = getRoute(router, action: "upload"), let url = getUrl(router, route: route, params: &params) {
            var request = HttpMultipartRequest(
                URL: url,
                data: data,
                params: params,
                handler: prepareHttpRequestHandler(router, route: route, onComplete: handler)
            )
            
            if let rawauth = route.auth, auth = AuthorizationType(rawValue: rawauth), service = Api.shared.getAuthorizationService(auth) {
                request.authorize(service)
            }
            
            return request
        } else {
            fatalError("No Endpoint for \(router).upload")
        }
        
        return nil
    }

    private func getRoute(router: Router, action: String) -> Route? {
        if let endpoint = getEndpoint(router), let route = endpoint.getRoute(action) {
            return route
        }
        
        return nil
    }
    
    private func getUrl(router: Router, route: Route, inout params: [String:AnyObject]) -> NSURL? {
        let versionpath: String = (self.flags & SHOW_VERSION_IN_PATH > 0) ? "/\(version)/" : ""
 
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
                    if let json = data.parseJson() {
                        onComplete(router.construct(json, node: route.node))
                    } else {
                        onComplete(nil)
                    }
                }
            default: // includes save, upload, and destroy
                return { data in
                    onComplete(data.parseJson())
                }
        }
    }
    
    private func getEndpoint(var router: Router?) -> Endpoint? {
        var endpoints = self.endpoints
        var lastEndpoint: Endpoint? = nil

        var components: [Router] = router?.getOwnershipHierarchy() ?? [Router]()
        
        for component in components {
            if let endpoint = endpoints[component.endpoint] {
                lastEndpoint = endpoint
                endpoints = lastEndpoint!.endpoints
                //println("Next Endpoints \(endpoints)")
            } else if let endpoint = endpoints[component.endpoint.pluralize()] {
                lastEndpoint = endpoint
                endpoints = lastEndpoint!.endpoints
            }
        }
        
        return lastEndpoint
    }
    
    override public var description: String {
        var str = ""
        
        for (key, endpoint) in endpoints {
            var description = endpoint.getDescription()
            str += "\n\(description)"
        }
        
        return str
    }
}

