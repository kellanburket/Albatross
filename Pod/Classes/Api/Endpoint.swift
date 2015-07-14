//
//  Endpoint.swift
//  Pods
//
//  Created by Kellan Cummings on 6/11/15.
//
//

import Foundation

internal class Endpoint: ActiveUrlPath {
    
    var type: String
    var routes = [String: Route]()
    
    init(type: String, values: [String: AnyObject], parent: ActiveUrlPath? = nil) {
        self.type = type
        super.init(parent: parent)

        for (str, value) in values {
            switch str {
                case "path":
                    if let path = value as? String {
                        self.path = path
                    } else {
                        fatalError("`path` must be a String")
                    }
                case "routes":
                    if let hash = value as? [String: AnyObject] {
                        for (method, route) in hash {
                            if let args = route as? [String: AnyObject] {
                                //println("Setting Route \(method)")
                                self.routes[method] = Route(action: method, endpoint: self, args: args)
                            } else {
                                fatalError("'\(method)' must be an instance of `[String: AnyObject]`")
                            }
                        }
                    }
                case "endpoints":
                    if let hash = value as? [String: AnyObject] {
                        for (model, endpoint) in hash {
                            if let args = endpoint as? [String: AnyObject] {
                                //println("Setting Endpoint \(model)")
                                self.endpoints[model] = Endpoint(type: model, values: args, parent: self)
                            }
                        }
                    }
                default:
                    fatalError("Endpoints may only have `methods`, `properties`, or `path` attributes. '\(str)' for endpoint '\(type)' not an acceptable attribute.")
            }
        }
    }
    
    func getRoute(action: String) -> Route? {
        //println("Routes (\(action)): \(routes)")
        return routes[action]
    }
    
    override func getDescription(_ tabs: Int = 0) -> String {
        var str = "\t".repeat(tabs) + "(\(type)):\(path)\n"
        
        for (key, ep) in endpoints {
            var description = ep.getDescription(tabs + 1)
            str += "\(description)"
        }
        
        for (method, r) in routes {
            var description = r.getDescription(tabs + 1)
            str += "\(description)"
        }
        
        return str
    }
}