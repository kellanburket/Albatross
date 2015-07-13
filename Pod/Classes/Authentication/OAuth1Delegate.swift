//
//  OAuth1Delegate.swift
//  Pods
//
//  Created by Kellan Cummings on 7/6/15.
//
//

import Foundation

public protocol OAuth1Delegate {
    func accessTokenHasBeenFetched(accessToken: String, accessTokenSecret: String)
}