//
//  RavelryOAuth1Helper.swift
//  Passenger
//
//  Created by Kellan Cummings on 7/8/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation
import Passenger

class RavelryOAuth1Helper: OAuth1Helper, OAuth1Delegate {
    
    override init() {
        super.init()
        
        if let service = Api.shared("ravelry").getAuthorizationService(AuthorizationType.OAuth1) as? OAuth1 {
            service.token = "FOVjUhuZN1Y9VeuXDJjnvk7JCgRir8Ob9uTJHv00"
            service.secret = "AhzI4ti7nXi28CrtYCYGWn1M037MJGn4RIt13MVj"
        }
    }
    
    override func getRequestToken() -> OAuth1Helper {
    
        if let service = Api.shared("ravelry").getAuthorizationService(AuthorizationType.OAuth1) as? OAuth1 {
            if service.token == nil || service.secret == nil {
                service.getRequestTokenUrl { secret, url in
                    if let url = url {
                        UIApplication.sharedApplication().openURL(url)
                    } else {
                        println("Request Token Url not discovered.")
                    }
                }
            } else {
                //println("Access Token:\(service.token)")
                //println("Access Token Secret:\(service.secret)")
            }
        } else {
            println("OAuth1 Service not implemented.")
        }
        
        return self
    }

    override func getAccessToken(url: NSURL) -> OAuth1Helper {

        if let service = Api.shared("ravelry").getAuthorizationService(AuthorizationType.OAuth1) as? OAuth1 {
            service.delegate = self
            let query = HttpRequest.parseQueryString(url)
            
            if let token = query["oauth_token"] as? String, verifier = query["oauth_verifier"] as? String {
                service.fetchAccessToken(token: token, verifier: verifier)
            } else {
                println("Could not parse query: \(query)")
            }
        } else {
            println("OAuth1 Service not implemented.")
        }
        
        return self
    }
}