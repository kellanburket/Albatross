//
//  BasicAuth.swift
//  Pods
//
//  Created by Kellan Cummings on 6/12/15.
//
//

import Foundation

/**
    Manages the construction of a `BasicAuth` HTTP header.
*/
public class BasicAuth: AuthorizationService {
    
    private var personalKey: String = ""

    override internal init(key: String, params: [String: AnyObject]) {
        if let pkey = params["personal_key"] as? String {
            self.personalKey = pkey
        }
        
        super.init(key: key, params: params)
    }
    
    override internal func setHeader(url: NSURL, inout request: NSMutableURLRequest) {
   
        let encodedAuth = "Basic " + "\(consumerKey):\(personalKey)".base64Encoded
        
        request.setValue(encodedAuth, forHTTPHeaderField: "Authorization")
    }
}