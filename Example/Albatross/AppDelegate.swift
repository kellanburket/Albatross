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
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        if let service = Api.shared.getAuthorizationService(AuthorizationType.OAuth1) as? OAuth1 {
            if service.accessToken == nil || service.accessTokenSecret == nil {
                service.getRequestTokenURL { url in
                    if let url = url {
                        UIApplication.sharedApplication().openURL(url)
                    } else {
                        println("Request Token Url not discovered.")
                    }
                }
            }
        } else {
            fatalError("OAuth1 Service not implemented.")
        }
        
        // Override point for customization after application launch.
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {

        println("Application will open url: \(url)")
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        println("Application Did Become Active")
    }
}

