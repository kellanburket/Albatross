//
//  HasManyRelationship.swift
//  Pods
//
//  Created by Kellan Cummings on 6/30/15.
//
//

import Foundation

public class HasManyRelationship<T: Passenger>: PassengerRelationship<T>, HasManyRouter {
 
    public var passengers = [Passenger]()
    
    override public init(_ owner: Passenger) {
        super.init(owner)
    }

    override internal func getClassName() -> String {
        return ("\(T.self)".split(".").last ?? "").pluralize()
    }

    public func list(onComplete: [T]? -> ()) {
        Api.shared.list(self) { records in
            if let passengers = records as? [T] {
                self.passengers = passengers
                onComplete(passengers)
            } else {
                onComplete(nil)
            }
        }
    }
    
    public func create(params: [String: AnyObject], onComplete: T? -> Void) {
        Api.shared.create(self, data: params) { record in
            if let passenger = record as? T {
                self.append(passenger)
                onComplete(passenger)
            } else {
                onComplete(nil)
            }
        }
    }
    
    public func find(id: Int, onComplete: T? -> Void) {
        Api.shared.find(self) { record in
            if let passenger = record as? T {
                self.append(passenger)
                onComplete(passenger)
            } else {
                onComplete(nil)
            }
        }
    }

    public override func serialize() -> [String: AnyObject] {
        var serial = [String: AnyObject]()
        for passenger in passengers {
            serial["\(passenger.id)"] = passenger.serialize()
        }
        return serial
    }
    
    public override func setPathVariables(var path: String) -> String {
        if let matches = path.scan("(?<=:)[\\w_\\.\\d]+(?=\\/|$)") {
            println("Setting Path Variables \(matches)")
            for arrMatch in matches {
                for match in arrMatch {
                    var submatch = match.split(".")
                    if submatch.count == 2 {
                        let type = submatch[0]
                        let field = submatch[1]
                        if let value: AnyObject = owner.getFieldValue(field) {
                            path = path.gsub(":\(match)", "\(value)")
                        }
                    }
                }
            }
        }
        
        return path
    }
    
    public func append(passenger: Passenger) {
        if let passenger = passenger as? T {
            let method = owner.asMethodName()
            if let relationship = passenger.belongsToRelationships[method] {
                relationship.registerPassenger(owner)
            }
        }
    }

    public subscript(index: Int) -> Passenger? {
        get {
            if passengers.count > index {
                return passengers[index]
            }
            
            return nil
        }
    }
}