//
//  OAuth1Delegate.swift
//  Pods
//
//  Created by Kellan Cummings on 7/6/15.
//
//

import Foundation

/**
    Delegate that returns response from `OAuth1.fetchAccessToken`.
*/
public protocol OAuth1Delegate {
    /**
        Returns affirmitive response when access token has been fetched from the server.
    
        :param: accessToken the access token
        :param: accessTokenSecret   the access token secret
    */
    func accessTokenHasBeenFetched(accessToken: String, accessTokenSecret: String)
}