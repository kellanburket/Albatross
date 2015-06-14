//
//  Http.swift
//  Pods
//
//  Created by Kellan Cummings on 6/10/15.
//
//

import Foundation
import Wildcard

public class Http: NSObject {

    lazy var queue: NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "HttpOperationQueue"
        queue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount
        return queue
    }()

    class FetchOperation: NSOperation {
        
        let request: HttpRequest
        let method: HttpMethod
        
        init(request: HttpRequest, method: HttpMethod) {
            self.request = request
            self.method = method
        }
        
        override func main() {
            getSession().dataTaskWithRequest(request.prepare(method), completionHandler: request.onComplete).resume()
        }
        
        func getSession() -> NSURLSession {
            var sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            
            var session = NSURLSession(configuration: sessionConfig)
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            return session
        }
    }

    override private init() {
        super.init()
    }
    
    public class func post(request: HttpRequest) {
        var obj = Http()
        obj.doAsyncRequest(request, method: HttpMethod.Post)
    }

    public class func get(request: HttpRequest) {
        var obj = Http()
        obj.doAsyncRequest(request, method: HttpMethod.Get)
    }

    public class func put(request: HttpRequest) {
        var obj = Http()
        obj.doAsyncRequest(request, method: HttpMethod.Put)
    }

    public class func delete(request: HttpRequest) {
        var obj = Http()
        obj.doAsyncRequest(request, method: HttpMethod.Delete)
    }
    
    func doAsyncRequest(request: HttpRequest, method: HttpMethod) {
        queue.addOperation(FetchOperation(request: request, method: method))
    }
}