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
    var node: String?
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
                case "method": //Overwite Default Method
                    //println("Overwriting Default Method \(arg)")
                    if let method = HttpMethod(rawValue: arg as! String) {
                        self.method = method
                    }
                case "node": //Overwrite Default Data Node
                    self.node = "\(arg)"
                default:
                    if let arguments = arg as? [String: AnyObject] {
                        endpoints[parameter] = Endpoint(type: parameter, values: arguments, parent: self)
                    } else {
                        fatalError("Endpoints must be instances of NSDictionary")
                    }
            }
        }
    }

    internal func applyArguments(router: Router) -> String {
        var str = getFullUrlString()        
        //println("Applying Args")
        var components: [Router] = router.getOwnershipHierarchy().reverse()
        
        var hash = [String: Router]()

        for component in components {
            hash[component.endpoint.decapitalize()] = component
        }
        
        //println("Path: \(str)")
        if let matches = str.scan("(?<=:)[\\w_\\-\\.\\d]+(?=\\/|$)") {
            //println("Setting Path Variables \(matches)")
            for arrMatch in matches {
                for match in arrMatch {
                    if let submatch: [String] = match.match("([\\w_\\-\\d]+?)\\.([\\w_\\-\\d]+)") {
                        var type = submatch[1]
                        var field = submatch[2]
                        
                        if let obj = hash[type] as? Passenger {
                            //println("\tobj is passenger: \(obj), \(field)")
                            if let value: AnyObject = obj.getFieldValue(field) {
                                str = str.gsub(":\(match)", "\(value)")
                            }
                        }
                    } else if let obj = components[0] as? Passenger, value: AnyObject = obj.getFieldValue(match)  {
                        str = str.gsub(":\(match)", "\(value)")
                    }
                }
            }
        }
        
        return str
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