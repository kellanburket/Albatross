//
//  Typealiases.swift
//  Pods
//
//  Created by Kellan Cummings on 7/4/15.
//
//

import Foundation

public typealias Json = [String: AnyObject]
public typealias onJsonRetrieved = Json? -> Void

public typealias onMediaRetrieved = Media? -> Void
public typealias onMediasRetrieved = [Media]? -> Void
public typealias onPassengerRetrieved = Passenger? -> Void
public typealias onPassengersRetrieved = [Passenger]? -> Void
public typealias onPassengerOperationSuccess = Bool -> Void