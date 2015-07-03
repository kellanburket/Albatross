//
//  Route.swift
//  Pods
//
//  Created by Kellan Cummings on 6/11/15.
//
//

import Foundation

public class Route: ActiveUrlPath {
    
    var method: HttpMethod?
    var action: String
    var auth: String?
    var contentType: HttpMediaType = HttpMediaType.Json
    var accept: [HttpMediaType] = [HttpMediaType.Json]

    public init(action: String, endpoint: ActiveUrlPath, args: [String: AnyObject]) {
        self.action = action
        super.init(parent: endpoint)

        if let method = HttpMethod.match(action) {
            self.method = method
        }
        //println("Setting \(self.action) => \(self.method)")
        //println("\t\tSetting Route \(method.rawValue)")
        for (parameter, arg) in args {
            //println("\t\t\tSetting Route Parameter '\(parameter)'")
            switch parameter {

                case "auth":
                    if let auth = arg as? String {
                        self.auth = auth
                    }
                case "path":
                    if let path = arg as? String {
                        self.path = path
                    } else {
                        fatalError("Path must be a string.")
                    }
                case "method": //Overrite Default Method
                    //println("Overwriting Default Method \(arg)")
                    if let method = HttpMethod(rawValue: arg as! String) {
                        self.method = method
                    }
                default:
                    if let arguments = arg as? [String: AnyObject] {
                        endpoints[parameter] = Endpoint(type: parameter, values: arguments, parent: self)
                    } else {
                        fatalError("Endpoints must be instances of NSDictionary")
                    }
            }
        }
    }

    public func applyArguments(router: Router) -> String {
        var str = getFullUrlString()        
        println("Applying Args")
        return router.setPathVariables(str)
    }
    
    override public func getDescription(_ tabs: Int = 0) -> String {
        var str = "\t".repeat(tabs) + "\(path)\n"
        
        for (key, ep) in endpoints {
            var description = ep.getDescription(tabs + 1)
            str += "\n\(description)"
        }
        
        return str
    }
}