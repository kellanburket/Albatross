//
//  PassengerMedia.swift
//  Pods
//
//  Created by Kellan Cummings on 7/3/15.
//
//


import Foundation

private var queue: NSOperationQueue = {
    var queue = NSOperationQueue()
    queue.name = "MediaLoadingQueue"
    queue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount
    return queue
}()

/**
    Base class for loading media objects from Urls. Any `Model` property which could take a Url type can take a media type instead.
*/
public class Media: ApiObject {

    /**
        The raw media URL
    */
    public var url: NSURL?


    /**
        The delegate to be called on image load success/failure
    */
    public var delegate: MediaLoadDelegate?

    /**
        Operation queue priority level
    */
    public var priority: NSOperationQueuePriority = .Normal
    
    private lazy var request: HttpRequest? = {
        if let url = self.url {
            return HttpRequest(URL: url, method: HttpMethod.Get, params: [String: AnyObject]()) { data, response, error in
                
                if let response = response as? NSHTTPURLResponse {
                    switch response.statusCode {
                    case 200:
                        //println("\t(200)\tSuccess")
                        self.loadMedia(data)
                    default:
                        println("\t\(response.statusCode)\t\(response)")
                        if let delegate = self.delegate {
                            delegate.mediaDidNotLoad(self)
                        }
                    }
                } else {
                    println("\tError\t\(error)")
                    if let delegate = self.delegate {
                        delegate.mediaDidNotLoad(self)
                    }
                }
                
            }
        } else {
            println("No Url Set.")
            return nil
        }
    }()
    
    internal func loadMedia(data: NSData) {
        fatalError("Must Override Method")
    }
    
    /**
        Attempts to load an image from the server using it's `url` property
        
        :param: delegate    A delegate to handle the load results
        :param: queue   The background queue to add the image loading process to, defaults to in-class queue
        :param: priority    The priority level of the operation, defaults to `.Normal`
    */
    public func load(delegate: MediaLoadDelegate? = nil, queue: NSOperationQueue? = nil, priority: NSOperationQueuePriority = .Normal) {
        self.delegate = delegate
        
        if let request = request {
            Http.get(request, queue: queue ?? queue, priority: priority)
        } else {
            println("No Http request set for '\(self.url)'")
        }
    }
    
    convenience public init(url: NSURL) {
        self.init()
        self.url = url
    }

    required public init(_ properties: [String: AnyObject] = [String: AnyObject]()) {
        super.init(properties)
    }
}