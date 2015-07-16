//
//  Typealiases.swift
//  Pods
//
//  Created by Kellan Cummings on 7/4/15.
//
//

import Foundation

/**
    Convenience typealiases for retrieval of single `Media` object
*/
public typealias onMediaRetrieved = Media? -> Void

/**
    Convenience typealiases for retrieval of multiple `Media` objects
*/
public typealias onMediasRetrieved = [Media]? -> Void

/**
    Convenience typealiases for retrieval of single `Model` object
*/
public typealias onModelRetrieved = Model? -> Void

/**
    Convenience typealiases for retrieval of multiple `Model` objects
*/
public typealias onModelsRetrieved = [Model]? -> Void