//
//  AuthorizationType.swift
//  Pods
//
//  Created by Kellan Cummings on 7/4/15.
//
//

import Foundation

/**
    Supported authorization types. Currently only OAuth1 and BasicAuth are supported; OAuth2 should enter development shortly. The raw value represents the HTTP Authorization header value.
*/
public enum AuthorizationType: String {
    case OAuth1 = "OAuth1"
    case OAuth2 = "OAuth2"
    case Basic = "BasicAuth"
}