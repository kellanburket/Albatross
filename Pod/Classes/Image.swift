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

    public var height = Double()
    public var width = Double()
    
    public var h: Double {
        get {
            return height
        }
        
        set(newHeight) {
            height = newHeight
        }
    }

    public var w: Double {
        get {
            return width
        }
        
        set(newWidth) {
            width = newWidth
        }
    }

    public var delegate: ImageLoadDelegate?

    internal var priority: NSOperationQueuePriority = .Normal
    
    private lazy var request: HttpRequest? = {
        if let url = self.url {
            return HttpRequest(URL: url, method: HttpMethod.Get, params: [String: AnyObject]()
                ) { data, response, url in
                    
                if data != nil {
                    if let image = UIImage(data: data) {
                        self.loadImage(image)
                    } else {
                        if let delegate = self.delegate {
                            delegate.imageDidNotLoad(self)
                        }
                        //self.loadImage(UIImage(named: "missing-photo")!)
                    }
                } else {
                    if let delegate = self.delegate {
                        delegate.imageDidNotLoad(self)
                    }
                    //self.loadImage(UIImage(named: "missing-photo")!)
                }
            }
        } else {
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
        }
    }
    
    func loadImage(image: UIImage) {
        self.image = image
        if let delegate = delegate {
            delegate.imageDidLoad(self)
        }
    }
}