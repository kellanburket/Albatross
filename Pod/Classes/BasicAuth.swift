//
//  BasicAuth.swift
//  Pods
//
//  Created by Kellan Cummings on 6/12/15.
//
//

import Foundation

public class BasicAuth: AuthenticationService {
    
    var personalKey: String = ""
    var consumerKey: String = ""

    override init(_ args: NSDictionary) {
        if let pkey = args["personal_key"] as? String {
            self.personalKey = pkey
        }
        
        if let ckey = args["consumer_key"] as? String {
            self.consumerKey = ckey
        }
        super.init(args)
    }
    
    override public func setHeader(url: NSURL, parameters: [String: AnyObject], inout request: NSMutableURLRequest) {
   
        let encodedAuth = "Basic " + "\(consumerKey):\(personalKey)".base64Encoded
        
        request.setValue(encodedAuth, forHTTPHeaderField: "Authorization")
    }
}