//
//  AppDelegate.swift
//  Passenger
//
//  Created by Kellan Cummings on 06/10/2015.
//  Copyright (c) 06/10/2015 Kellan Cummings. All rights reserved.
//

import UIKit
import CoreData
import Passenger

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var oauthHelper: OAuth1Helper?
    
    var requestTokenSecret: String?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //println("Application Did Finish Launching With Options")
        oauthHelper = TwitterOAuth1Helper().getRequestToken()
        
        // Override point for customization after application launch.
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {

        //println("Application will open url: \(url)")
        if let helper = oauthHelper {
            helper.getAccessToken(url)
        }
        
        return false
    }
}


