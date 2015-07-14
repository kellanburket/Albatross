//
//  TwitterOAuth1Helper.swift
//  Passenger
//
//  Created by Kellan Cummings on 7/8/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation
import Passenger

class TwitterOAuth1Helper: OAuth1Helper {
    
    override init() {
        super.init()
        
        if let service = Api.shared().getAuthenticationService(AuthenticationType.OAuth1) as? OAuth1 {
            service.token = "3270562178-EKvfMjCLUJinVd2CzSXRB1fASUTMHwR5jng4O8J"
            service.secret = "mt3K6B05FOebpcD6dE51CXcv4Y7AywYU1gQnvx5lO8W3M"
        }
    }
    
    override func getRequestToken() -> OAuth1Helper {
        
        if let service = Api.shared().getAuthenticationService(AuthenticationType.OAuth1) as? OAuth1 {
            if service.token == nil || service.secret == nil {
                service.getRequestTokenURL { secret, url in
                    if let url = url {
                        UIApplication.sharedApplication().openURL(url)
                    } else {
                        println("Request Token Url not discovered.")
                    }
                }
            } else {
                println("Access Token:\(service.token)")
                println("Access Token Secret:\(service.secret)")
            }
        } else {
            println("OAuth1 Service not implemented.")
        }
        
        return self
    }
    
    override func getAccessToken(url: NSURL) -> OAuth1Helper {
        
        if let service = Api.shared().getAuthenticationService(AuthenticationType.OAuth1) as? OAuth1 {
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

    override func accessTokenHasBeenFetched(accessToken: String, accessTokenSecret: String) {
        super.accessTokenHasBeenFetched(accessToken, accessTokenSecret: accessTokenSecret)
        println("Access Token:\(accessToken)")
        println("Access Token Secret:\(accessTokenSecret)")
    }
}