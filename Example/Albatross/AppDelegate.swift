//
//  AppDelegate.swift
//  Albatross
//
//  Created by Kellan Cummings on 06/10/2015.
//  Copyright (c) 06/10/2015 Kellan Cummings. All rights reserved.
//

import UIKit
import CoreData
import Albatross

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, OAuth1Delegate {

    var window: UIWindow?
    var requestTokenSecret: String?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        println("Application Did Finish Launching With Options")

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
                println("Access Token:\(service.token)")
                println("Access Token Secret:\(service.secret)")
            }
        } else {
            println("OAuth1 Service not implemented.")
        }
        
        // Override point for customization after application launch.
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {

        println("Application will open url: \(url)")
        
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

        return false
    }

    func accessTokenHasBeenFetched(accessToken: String, accessTokenSecret: String) {
        println("Access Token: \(accessToken)")
        println("Access Token Secret: \(accessTokenSecret)")
    }
}


