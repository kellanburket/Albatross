//
//  AuthorizationService.swift
//  Pods
//
//  Created by Kellan Cummings on 6/10/15.
//
//

import Foundation

/**
    Abstract class that manages the construction of the `Authorization` header for HTTP requests.
*/
public class AuthorizationService: NSObject {
 
    internal var consumerKey: String
    internal var headers = [String: String]()
    internal let encoding: NSStringEncoding = NSUTF8StringEncoding
    
    internal init(key: String, params: [String: AnyObject]) {
        self.consumerKey = key
        super.init()
    }
    
    internal func setSignature(url: NSURL, parameters: [String:AnyObject], method: String, onComplete: () -> ()) {
        onComplete()
    }
    
    internal func setHeader(url: NSURL, inout request: NSMutableURLRequest) {

    }
}