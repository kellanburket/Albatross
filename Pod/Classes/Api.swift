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
    
    private var authorization = [String: AuthorizationService]()
    public var endpoints = [String: Endpoint]()
    
    internal override init() {
        //println("Initializing API")
        
        if let apiPath = NSBundle.mainBundle().pathForResource("api", ofType: "plist") {
            if let data = NSDictionary(contentsOfFile: apiPath) {
                //println("API Config \(data)")
                
                if let ns = data["namespace"] as? String {
                    namespace = ns
                }
            
                if let urlString = data["url"] as? String {
                    self.url = NSURL(string: urlString)
                }

                if let auth = data["authentication"] as? [String: AnyObject] {
                    for (key, value) in auth {
                        if let hash = value as? [String: AnyObject] {
                            //println("\(key) \(value)")
                            switch key {
                                case "OAuth1":
                                    authorization[key] = OAuth1(hash)
                                case "OAuth2":
                                    authorization[key] = OAuth2(hash)
                                default:
                                    authorization[key] = BasicAuth(hash)
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
            }
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
            }
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
    public func list(router: Router, onComplete: (AnyObject?) -> ()) {
        if let request = getRequest(router, action: "list", params: [String: AnyObject](), handler: onComplete) {
            Http.start(request)
        } else {
            onComplete(nil)
        }
    }

    //Get all in acollection that meet parameter
    public func search(router: Router, params: [String: AnyObject], onComplete: (AnyObject?) -> ()) {
        if let request = getRequest(router, action: "search", params: params, handler: onComplete) {
            Http.start(request)
        } else {
            onComplete(nil)
        }
    }

    //Get One In Collection
    public func find(router: Router, onComplete: (AnyObject?) -> ()) {
        if let request = getRequest(router, action: "find", params: [String: AnyObject](), handler: onComplete) {
            //println("Starting Find Request")
            Http.start(request)
        } else {
            onComplete(nil)
        }
    }
    
    //Create One in Collection
    public func create(router: Router, data: [String: AnyObject], onComplete: (AnyObject?) -> ()) {
        if let request = getRequest(router, action: "create", params: data, handler: onComplete) {
            Http.start(request)
        } else {
            onComplete(nil)
        }
    }
    
    //Destroy One Element
    public func destroy(router: Router, onComplete: (Bool) -> ()) {
        
        let handler: (AnyObject?) -> () = { obj in
            if let record = obj as? Passenger {
                onComplete(true)
            } else {
                onComplete(false)
            }
        }
        
        
        if let request = getRequest(router, action: "destroy", params: ["id": router.id], handler: handler) {
            Http.start(request)
        } else {
            onComplete(false)
        }
    }

    /*
    //Destroy Collection
    public func destroy(type: Passenger.Type, onComplete: (Bool) -> ()) {
        println("Destroying \(type)")
    }
    */
    
    //Save Element
    public func save(router: Router, data: [String: AnyObject], onComplete: (Bool) -> ()) {

        var handler: (AnyObject?) -> () = { raw in
            println("Handling Save Request \(raw)")
            if let record = raw as? Passenger {
                onComplete(true)
            } else {
                onComplete(false)
            }
        }
        
        if let request = getRequest(router, action: "save", params: data, handler: handler) {
            Http.start(request)
        } else {
            onComplete(false)
        }
    }
    
    public var basepath: String? {
        return url?.absoluteString
    }
    
    internal func getAuthorizationService(method: String) -> AuthorizationService? {
        return authorization[method]
    }

    private func getRequest(router: Router, action: String, var params: [String: AnyObject], handler: (AnyObject?) -> ()) -> HttpRequest? {

        let type = router.getType()

        if let route = getRoute(router, action: action), let url = getUrl(router, route: route, params: &params) {
            
            var request: HttpRequest
            
            if route.method == .Delete || route.action == "list" {
                request = HttpRequest(
                    URL: url,
                    method: route.method ?? HttpMethod.Get,
                    handler: prepareHttpRequestHandler(type, onComplete: handler)
                )
            } else {
                request = HttpRequest(
                    URL: url,
                    method: route.method ?? HttpMethod.Get,
                    params: params,
                    handler: prepareHttpRequestHandler(type, onComplete: handler)
                )
            }
            
            if let auth = route.auth, service = Api.shared.getAuthorizationService(auth) {
                request.authorize(service)
            }
            
            return request
        } else {
            fatalError("No Endpoint for \(type.className).\(action)")
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
        
        println("ROUTE PATH: \(routepath)")
        
        var fileExtension = ""

        if let mediaType = route.contentType.fileExtension {
            fileExtension += ".\(mediaType)"
        }
        
        let extensionpath: String = (self.flags & USE_FILE_EXTENSIONS > 0) ? fileExtension  : ""
        let urlpath: String = basepath ?? ""
        
        return NSURL(string: "\(urlpath)\(versionpath)\(routepath)\(extensionpath)")
    }
    
    private func prepareHttpRequestHandler(type: Passenger.Type, onComplete: (AnyObject?) -> ()) -> (NSData!) -> () {
        return { data in
            if let json = data.parseJson() {
                //println("JSON Parsed")
                onComplete(type.parse(json))
            } else {
                println("Unable to Parse JSON")
                onComplete(nil)
            }
        }
    }
    
    private func getEndpoint(var router: Router?) -> Endpoint? {
        var endpoints = self.endpoints
        var lastEndpoint: Endpoint? = nil
        //println("Endpoints \(endpoints)")
        //println("COMPONENTS \(components)")
        var components: [Router] = [router!]
        
        while let parent = router?.parent {
            components.append(parent)
            router = router?.parent
        }
        
        components = components.reverse()
        
        for component in components {
            //println("Getting Endpoint for \(component)")
            if let passenger = component as? Passenger {
                if let endpoint = endpoints[passenger.asMethodName()] {
                    lastEndpoint = endpoint
                    endpoints = lastEndpoint!.endpoints
                    //println("Next Endpoints \(endpoints)")
                } else if let endpoint = endpoints[passenger.asMethodName().pluralize()] {
                    lastEndpoint = endpoint
                    endpoints = lastEndpoint!.endpoints
                }
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

