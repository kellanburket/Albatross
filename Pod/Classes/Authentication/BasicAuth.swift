//
//  BasicAuth.swift
//  Pods
//
//  Created by Kellan Cummings on 6/12/15.
//
//

import Foundation

public class BasicAuth: AuthorizationService {
    
    var personalKey: String = ""

    override public init(key: String, params: [String: AnyObject]) {
        if let pkey = params["personal_key"] as? String {
            self.personalKey = pkey
        }
        
        super.init(key: key, params: params)
    }
    
    override public func setHeader(url: NSURL, inout request: NSMutableURLRequest) {
   
        let encodedAuth = "Basic " + "\(consumerKey):\(personalKey)".base64Encoded
        
        request.setValue(encodedAuth, forHTTPHeaderField: "Authorization")
    }
}