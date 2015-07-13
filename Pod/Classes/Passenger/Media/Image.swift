//
//  Image.swift
//  Pods
//
//  Created by Kellan Cummings on 7/3/15.
//
//

import Foundation

public protocol ImageLoadDelegate {
    func imageDidLoad(image: Image)
    func imageDidNotLoad(image: Image)
}

public class Image: Media {

    public var image: UIImage?

    public var delegate: ImageLoadDelegate?

    internal var priority: NSOperationQueuePriority = .Normal
    
    private lazy var request: HttpRequest? = {
        if let url = self.url {
            return HttpRequest(URL: url, method: HttpMethod.Get, params: Json()) { data, response, error in
                
                if let response = response as? NSHTTPURLResponse {
                    switch response.statusCode {
                        case 200:
                            println("\t(200)\tSuccess")
                            if let image = UIImage(data: data) {
                                self.loadImage(image)
                            } else {
                                if let delegate = self.delegate {
                                    delegate.imageDidNotLoad(self)
                                }
                            }
                        default:
                            println("\t\(response.statusCode)\t\(response)")
                            if let delegate = self.delegate {
                                delegate.imageDidNotLoad(self)
                            }
                    }
                } else {
                    println("\tError\t\(error)")
                    if let delegate = self.delegate {
                        delegate.imageDidNotLoad(self)
                    }
                }
                
            }
        } else {
            println("No Url Set.")
            return nil
        }
    }()
    
    private lazy var queue: NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "ImageLoadingQueue"
        queue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount
        return queue
    }()

    public func load(delegate: ImageLoadDelegate? = nil, queue: NSOperationQueue? = nil, priority: NSOperationQueuePriority = .Normal) {
        self.delegate = delegate
        
        if let request = request {
            Http.get(request, queue: queue ?? self.queue, priority: priority)
        } else {
            println("No Http request set for '\(self.url)'")
        }
    }
    
    func loadImage(image: UIImage) {
        self.image = image
        if let delegate = delegate {
            delegate.imageDidLoad(self)
        }
    }
}