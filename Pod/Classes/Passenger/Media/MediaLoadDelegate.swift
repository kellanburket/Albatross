//
//  MediaLoadDelegate.swift
//  Pods
//
//  Created by Kellan Cummings on 7/14/15.
//
//

import Foundation


/**
Delegate that manages downloading and processing of media from the server
*/
public protocol MediaLoadDelegate {
    /**
    Called when media has been successfully loaded from the server and processed
    */
    func mediaDidLoad(media: Media)
    
    /**
    Called when media was not successfully loaded from the server
    */
    func mediaDidNotLoad(media: Media)
}