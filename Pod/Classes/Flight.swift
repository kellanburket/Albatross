//
//  Flight.swift
//  Pods
//
//  Created by Kellan Cummings on 6/28/15.
//
//

import Foundation

public class Flight: NSObject {

    private var passengers: [Passenger]

    public var count: Int {
        return passengers.count
    }

    public init(passengers: [Passenger]) {
        self.passengers = passengers
    }
    
    public subscript(index: Int) -> Passenger {
        return passengers[index]
    }
}