//
//  Http.swift
//  Pods
//
//  Created by Kellan Cummings on 6/10/15.
//
//

import Foundation
import Wildcard

internal class Http: NSObject {
    
    var operationQueue: NSOperationQueue!
    var operationQueuePriority: NSOperationQueuePriority
    
    lazy var defaultOperationQueue: NSOperationQueue = {
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
            //println("Preparing Request")
            request.prepare() { result in
                //println("Sending Request \(self.method.rawValue) \(self.request.url)")
                self.getSession().dataTaskWithRequest(result, completionHandler: self.request.onComplete).resume()
            }
        }
        
        func getSession() -> NSURLSession {
            var sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            
            var session = NSURLSession(configuration: sessionConfig)
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            return session
        }
    }

    private init(queue: NSOperationQueue? = nil, priority: NSOperationQueuePriority = .Normal) {
        self.operationQueuePriority = priority
        super.init()
        self.operationQueue = queue ?? defaultOperationQueue
    }
    
    class func start(request: HttpRequest, queue: NSOperationQueue? = nil, priority: NSOperationQueuePriority = .Normal) {
        Http(queue: queue, priority: priority).doAsyncRequest(request, method: request.method ?? HttpMethod.Get)
    }
    
    class func post(request: HttpRequest, queue: NSOperationQueue? = nil, priority: NSOperationQueuePriority = .Normal) {
        Http(queue: queue, priority: priority).doAsyncRequest(request, method: HttpMethod.Post)
    }

    class func get(request: HttpRequest, queue: NSOperationQueue? = nil, priority: NSOperationQueuePriority = .Normal) {
        Http(queue: queue, priority: priority).doAsyncRequest(request, method: HttpMethod.Get)
    }

    class func put(request: HttpRequest, queue: NSOperationQueue? = nil, priority: NSOperationQueuePriority = .Normal) {
        Http(queue: queue, priority: priority).doAsyncRequest(request, method: HttpMethod.Put)
    }

    class func delete(request: HttpRequest, queue: NSOperationQueue? = nil, priority: NSOperationQueuePriority = .Normal) {
        Http(queue: queue, priority: priority).doAsyncRequest(request, method: HttpMethod.Delete)
    }
    
    func doAsyncRequest(request: HttpRequest, method: HttpMethod) {
        //println("Doing Asynchronous Request \(method.rawValue) ... currently in queue count \(queue.operationCount)")
        
        operationQueue.addOperation(FetchOperation(request: request, method: method))
    }
}