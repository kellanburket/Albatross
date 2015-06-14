//
//  Api.swift
//  Pods
//
//  Created by Kellan Cummings on 6/10/15.
//
//

import Foundation
//import Reflektor

private var api = Api()

public class Api: NSObject {
    
    private var url: NSURL?
    private var authorization = [String: AuthenticationService]()
    public var endpoints = [Endpoint]()
    
    private override init() {
        if let apiPath = NSBundle.mainBundle().pathForResource("api", ofType: "plist") {
            if let data = NSDictionary(contentsOfFile: apiPath) {
                if let urlString = data["URL"] as? String {
                    self.url = NSURL(string: urlString)
                }

                if let auth = data["Authorization"] as? NSDictionary {
                    for (key, value) in auth {
                        if let hash = value as? NSDictionary {
                            switch key as! String {
                                case "OAuth1":
                                    println("OAuth1")
                                    authorization["\(key)"] = OAuth1(hash)
                                case "OAuth2":
                                    println("OAuth2")
                                    authorization["\(key)"] = OAuth1(hash)
                                default:
                                    println("Default")
                                    authorization["\(key)"] = BasicAuth(hash)
                            }
                        }
                        //if let authService = ClassReflektor.create(key as! String) as? AuthenticationService {   authorization["\(key)"] = authService }
                    }
                }
            }
        }
        
        if let endpointsPath = NSBundle.mainBundle().pathForResource("endpoints", ofType: "plist") {
            if let data = NSDictionary(contentsOfFile: endpointsPath) {
                for (key, value) in data {
                    if let endpoint = value as? NSDictionary {
                        self.endpoints.append(Endpoint(type: key as! String, values: endpoint))
                    }

                }
            }
        }
    }
    
    public class var shared: Api {
        return api
    }

    public func search(type: ActiveRecord.Type, id: Int, onComplete: (AnyObject) -> ()) {
        println("Searching \(type)")
    }

    public func fetch(type: ActiveRecord.Type, onComplete: (AnyObject) -> ()) {
        println("Fetching \(type)")
    }

    public func find(type: ActiveRecord.Type, id: Int, onComplete: (AnyObject) -> ()) {
        println("Finding \(type)")
    }
    
    public func create(type: ActiveRecord.Type, data: [String: AnyObject], onComplete: (AnyObject) -> ()) {
        println("Creating \(type)")
    }
    
    public func destroy(type: ActiveRecord.Type, id: Int, onComplete: (AnyObject) -> ()) {
        println("Destroying \(type)")
    }

    public func save(type: ActiveRecord.Type, data: [String: AnyObject], onComplete: (AnyObject) -> ()) {
        println("Saving \(type)")
    }
}

