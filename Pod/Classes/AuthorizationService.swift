//
//  AuthorizationService.swift
//  Pods
//
//  Created by Kellan Cummings on 6/10/15.
//
//

import Foundation

public class AuthorizationService: NSObject {
 
    internal var consumerKey: String
    var headers = [String: String]()
    let encoding: NSStringEncoding = NSUTF8StringEncoding
    
    public init(key: String, params: [String: AnyObject]) {
        self.consumerKey = key
        super.init()
    }
    
    public func setSignature(url: NSURL, parameters: [String:AnyObject], method: String, onComplete: () -> ()) {
        onComplete()
    }
    
    public func setHeader(url: NSURL, inout request: NSMutableURLRequest) {

    }
}