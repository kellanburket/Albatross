//
//  RavelryOAuth1Helper.swift
//  Albatross
//
//  Created by Kellan Cummings on 7/8/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation
import Albatross

class RavelryOAuth1Helper: OAuth1Helper, OAuth1Delegate {
    
    override func getRequestToken() -> OAuth1Helper {
    
        if let service = Api.shared.getAuthorizationService(AuthorizationType.OAuth1) as? OAuth1 {
            if service.token == nil || service.secret == nil {
                service.getRequestTokenURL { secret, url in
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

        if let service = Api.shared.getAuthorizationService(AuthorizationType.OAuth1) as? OAuth1 {
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