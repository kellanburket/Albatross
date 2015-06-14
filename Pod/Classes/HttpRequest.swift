//
//  HttpRequest.swift
//  Pods
//
//  Created by Kellan Cummings on 6/11/15.
//
//

import Foundation
import UIKit

public typealias HttpResponseHandler = (NSData!, NSURLResponse!, NSError!) -> ()

public protocol HttpSuccessDelegate {
    func actionHasSucceededWhereOthersHaveFailed()
    func actionHasFailedWhereOthersHaveSucceeded()
}

public protocol HttpResultsDelegate {
    func resultsHaveBeenFetched(data: NSData!)
}

public class HttpRequest {

    private var authenticationService: AuthenticationService?
    private var handler: HttpResponseHandler
    
    private var headers: [String:String] = [
        "Content-Type": HttpContentType.FormEncoded.description,
        "Accept": HttpContentType.Json.description
    ]
    
    private var parameters = [String:AnyObject]()

    private var baseUrl: NSURL
    
    public var contentType: String? {
        get {
            return headers["Content-Type"]
        }
        set(contentType) {
            headers["Content-Type"] = contentType
        }
    }

    public var accept: String? {
        get {
            return headers["Accept"]
        }
        set(contentType) {
            headers["Accept"] = contentType
        }
    }
    
    public var onComplete: HttpResponseHandler {
        return handler
    }
    
    

    public init(URL: NSURL, params: [String:AnyObject], handler: HttpResponseHandler) {
        self.baseUrl = URL
        self.parameters = params
        self.handler = handler
    }

    public convenience init(URL: NSURL, params: [String:AnyObject], handler: (NSData!) -> ()) {
        self.init(URL: URL, params: [String:AnyObject](), handler: HttpRequest.getDefaultCompletionHandler(handler))
    }
    
    public convenience init(URL: NSURL, params: [String:AnyObject], delegate: HttpResultsDelegate) {
        self.init(URL: URL, params: params, handler: HttpRequest.getDefaultCompletionHandler(delegate))
    }
    
    public convenience init(URL: NSURL, params: [String:AnyObject], delegate: HttpSuccessDelegate) {
        self.init(URL: URL, params: params, handler: HttpRequest.getDefaultCompletionHandler(delegate))
    }
    
    public convenience init(URL: NSURL, delegate: HttpResultsDelegate) {
        self.init(URL: URL, params: [String:AnyObject](), handler: HttpRequest.getDefaultCompletionHandler(delegate))
    }
    
    public convenience init(URL: NSURL, delegate: HttpSuccessDelegate) {
        self.init(URL: URL, params: [String:AnyObject](), handler: HttpRequest.getDefaultCompletionHandler(delegate))
    }

    public convenience init(URL: NSURL, handler: (NSData!) -> ()) {
        self.init(URL: URL, params: [String:AnyObject](), handler: HttpRequest.getDefaultCompletionHandler(handler))
    }

    public func authorize(service: AuthenticationService) {
        self.authenticationService = service
    }
    
    public func prepare(method: HttpMethod) -> NSMutableURLRequest {
        
        if let service = authenticationService {
            service.setSignature(
                baseUrl,
                parameters: parameters,
                method: method.description,
                headers: &headers
            )
        }
        
        var request = generateRequestObject(method)

        if let service = authenticationService {
            service.setHeader(baseUrl, parameters: parameters, request: &request)
        }
        
        return request
    }
    
    public class func parseQuery(data: NSData, encoding: UInt) -> [String:String] {
        var arr = [String:String]()
        
        if let params = NSString(data: data, encoding: encoding) as? String {
            let parseParams = params.split("&")
            
            for param in parseParams {
                let values = param.split("=")
                if values.count > 1 {
                    arr[values[0]] = values[1]
                }
            }
        }
        
        return arr
    }
    
    public func setHeaders(headers: [String: String]) {
        for (header, value) in headers {
            setHeader(header, value: value)
        }
    }
    
    public func setHeader(header: String, value: String) {
        self.headers[header] = value
    }

    private func setRequestHeaders(inout request: NSMutableURLRequest) {
        for (header, value) in headers {
            request.setValue(value, forHTTPHeaderField: header)
        }
    }
    
    private func generateBoundaryString() -> String {
        return String(format:"---------------------------%@", generateNonce(digits: 12))
    }
        
    private func generateRequestObject(method: HttpMethod) -> NSMutableURLRequest {

        if method == HttpMethod.Get {
            baseUrl = NSURL(string: getAbsoluteURL())!
        }

        var request = NSMutableURLRequest(
            URL: baseUrl,
            cachePolicy: .ReturnCacheDataElseLoad,
            timeoutInterval: 120
        )
        
        request.HTTPMethod = method.description
        request.HTTPShouldHandleCookies = false

        setRequestHeaders(&request)

        switch method {
            case HttpMethod.Get:
                baseUrl = NSURL(string: getAbsoluteURL())!
            default:
                prepareBody(&request)
        }

        return request
    }
    
    private func sortParamaters() {
        var newParameters = [String: AnyObject]()
        var keys = [String](parameters.keys)
        keys.sort({ return $0 < $1 })
        
        for key in keys {
            newParameters[key] = parameters[key]!
        }
        
        parameters = newParameters
    }
    
    private func getAbsoluteURL() -> String {
        var urlString = baseUrl.absoluteString!
        var paramString = buildParamString()
        return "\(urlString)\(paramString)"
    }
    
    private func prepareBody(inout request: NSMutableURLRequest) {
        
        var bodyString = ""
        
        for (k, v) in parameters {
            var key = k.percentEncode()
            var value = "\(v)".gsub(" ", "+").percentEncode(ignore: ["+"])
            bodyString += "\(key)=\(value)&"
        }
        bodyString = bodyString.rtrim("& ")
        
        //println(bodyString)
        request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    private func buildParamString() -> String {
        if count(parameters) > 0 {
            var paramString = "?"
            
            var keys = [String](parameters.keys)
            keys.sort({ return $0 < $1 })
            
            for key in keys {
                var value = "\(parameters[key]!)"
                paramString += key.percentEncode()  + "=" + value.percentEncode(ignore: ["+", "-"])  + "&"
            }
            
            return paramString.rtrim("&")
        } else {
            return ""
        }
    }
    
    private class func getDefaultCompletionHandler(delegate: HttpResultsDelegate) -> HttpResponseHandler {
        return getDefaultCompletionHandler { data in
            delegate.resultsHaveBeenFetched(data)
        }
    }
    
    private class func getDefaultCompletionHandler(delegate: HttpSuccessDelegate) -> HttpResponseHandler {
        return { data, response, error in
            
            if let r = response as? NSHTTPURLResponse  {
                var statusCode = r.statusCode
                switch statusCode {
                    case 200:
                        delegate.actionHasSucceededWhereOthersHaveFailed()
                    default:
                        println(response)
                        delegate.actionHasFailedWhereOthersHaveSucceeded()
                    }
            } else {
                println(error)
                println(response)
                delegate.actionHasFailedWhereOthersHaveSucceeded()
            }
        }
    }
    
    private class func getDefaultCompletionHandler(handler: (NSData!) -> ()) -> HttpResponseHandler {
        return { data, response, error in
            
            if let r = response as? NSHTTPURLResponse  {
                var statusCode = r.statusCode
                switch statusCode {
                    case 200:
                        //println("Success: 200")
                        //println(data.toString())
                        handler(data)
                    case 403:
                        println("403: Resource Forbidden")
                        //AlertDialogueController("Resource Forbidden", "You are not permitted to access the selected resource.").present()
                    case 404:
                        println("404: Resource Not Found")
                        //AlertDialogueController("Resource Not Found", "The selected resource cannot be found.").present()
                    case 408:
                        println("408: Network Timeout")
                        //AlertDialogueController("Network Timeout", "The network timed out while attempting to complete your request.").present()
                    case 415:
                        println("415: Unsupported Media Type")
                        //AlertDialogueController("Unsupported Media Type", "You are attempting to upload an unsupported media type. The requested action cannot be completed.").present()
                    default:
                        //AlertDialogueController("Something went wrong.", "Please try your request again later.").present()
                        println("Status: \(statusCode)")
                        println("Response: \(response)")
                }
            } else {
                println(error)
                //AlertDialogueController("Network Connectivity Issue", "There was a problem establishing a connection to the server.").present()
            }
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
}