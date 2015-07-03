//
//  HasOneRelationship.swift
//  Pods
//
//  Created by Kellan Cummings on 6/30/15.
//
//

import Foundation

public class HasOneRelationship<T: Passenger>: PassengerRelationship<T>, HasOneRouter {

    public var passenger: Passenger? {
        didSet {
            if let p = passenger as? T {
                let method = owner.asMethodName()
                if let relationship = p.belongsToRelationships[method] {
                    relationship.registerPassenger(owner)
                }
            }
        }
    }
    
    override public var id: Int {
        return passenger?.id ?? 0
    }
    
    override public init(_ owner: Passenger) {
        super.init(owner)
    }
    
    public func create(params: [String: AnyObject], onComplete: Passenger? -> Void) {
        T(params).create { record in
            if let passenger = record as? T {
                self.passenger = passenger
                
                onComplete(self.passenger)
            } else {
                onComplete(nil)
            }
        }
    }
    
    public func find(id: Int, onComplete: Passenger? -> Void) {
        passenger = T(["id": id])

        Api.shared.find(self) { record in
            if let passenger = record as? T {
                self.passenger = passenger
                onComplete(self.passenger)
            } else {
                onComplete(nil)
            }
            
        }
    }
    
    public func destroy(onComplete: Bool -> Void) {
        if let passenger = self.passenger {
            passenger.destroy { success in
                if success {
                    self.passenger = nil
                }
                
                onComplete(success)
            }
        }
    }
    
    public func save(onComplete: Bool -> Void) {
        if let passenger = self.passenger {
            passenger.save(onComplete)
        }
    }
    
    public override func setPathVariables(var path: String) -> String {
        println("Path: \(path)")
        if let matches = path.scan("(?<=:)[\\w_\\.\\d]+(?=\\/|$)") {
            println("Setting Path Variables \(matches)")
            for arrMatch in matches {
                for match in arrMatch {
                    if let submatch = match.match("\\.") {
                        let type = submatch[0]
                        let field = submatch[1]
                        if let value: AnyObject = owner.getFieldValue(field) {
                            path = path.gsub(":\(match)", "\(value)")
                        }
                        
                    } else if let passenger = self.passenger {
                        path = passenger.setPathVariables(path)
                    }
                }
            }
        }
        
        return path
    }
    
    override public func serialize() -> [String: AnyObject] {
        
        if let passenger = self.passenger {
            return passenger.serialize()
        }
        
        return [String: AnyObject]()
    }
}