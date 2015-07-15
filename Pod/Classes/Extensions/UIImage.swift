//
//  UIImage.swift
//  Pods
//
//  Created by Kellan Cummings on 7/4/15.
//
//

import UIKit

internal extension UIImage {

    internal func toPngData() -> NSData {
        return UIImagePNGRepresentation(self)
    }
    
    internal func toJpgData(compressionQuality quality: CGFloat = 1.0) -> NSData {
        return UIImageJPEGRepresentation(self, quality)
    }
    
    internal var bytes: [UInt8] {
        let provider = CGImageGetDataProvider(self.CGImage)
        let data = CGDataProviderCopyData(provider)
        let length = CFDataGetLength(data)
        let range = CFRangeMake(0, length)
        
        var output = [UInt8](count: length, repeatedValue: 0)
        CFDataGetBytes(data, range, &output)
        
        //let radix = String(output[0], radix: 16)
        return output
    }
    
}