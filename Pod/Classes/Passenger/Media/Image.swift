//
//  Image.swift
//  Pods
//
//  Created by Kellan Cummings on 7/3/15.
//
//

import Foundation

/**
    Base class for Image Media
*/
public class Image: Media {

    /**
        The raw image
    */
    public var image: UIImage?

    override internal func loadMedia(data: NSData) {
        if let image = UIImage(data: data) {
            self.image = image
            if let delegate = delegate {
                delegate.mediaDidLoad(self)
            }
        } else {
            if let delegate = self.delegate {
                delegate.mediaDidNotLoad(self)
            }
        }

    }
    
    /**
        Converts a `UIImage` to its underlying JEPG data
    
        :param: image   the image to convert
    
        :returns:   underlying JPEG data
    */
    public class func toJpg(image: UIImage) -> NSData? {
        return image.toJpgData();
    }

    /**
        Converts a `UIImage` to its underlying PNG data
        
        :param: image   the image to convert
        
        :returns:   underlying PNG data
    */
    public class func toPng(image: UIImage) -> NSData? {
        return image.toPngData();
    }

}