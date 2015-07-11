//
//  OAuth1Helper.swift
//  Albatross
//
//  Created by Kellan Cummings on 7/8/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation
import Albatross

class OAuth1Helper: OAuth1Delegate {
    
    init() {
        
    }
    
    func getRequestToken() -> OAuth1Helper {
        
        return self
    }

    func getAccessToken(url: NSURL) -> OAuth1Helper {
        
        return self
    }

    func accessTokenHasBeenFetched(accessToken: String, accessTokenSecret: String) {
        //println("Access Token: \(accessToken)")
        //println("Access Token Secret: \(accessTokenSecret)")
    }

}