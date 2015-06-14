//
//  AuthenticationService.swift
//  Pods
//
//  Created by Kellan Cummings on 6/10/15.
//
//

import Foundation

public class AuthenticationService: NSObject {
 
    var headers = [String:String]()
    let encoding: NSStringEncoding = NSUTF8StringEncoding
    
    init(_ args: NSDictionary) {
        super.init()
    }
    
    public func setSignature(url: NSURL, parameters: [String:AnyObject], method: String, inout headers: [String:String]) {
        
    }
    
    public func setHeader(url: NSURL, parameters: [String: AnyObject], inout request: NSMutableURLRequest) {

    }
}