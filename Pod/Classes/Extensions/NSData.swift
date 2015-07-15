//
//  NSData.swift
//  Pods
//
//  Created by Kellan Cummings on 6/14/15.
//
//

import Foundation
import CommonCrypto

internal extension NSData {
    internal func parseJson() -> AnyObject? {
        var error: NSError?
        if let json = NSJSONSerialization.JSONObjectWithData(self, options: nil, error: &error) as? [String: AnyObject] {
            return json
        } else if let json = NSJSONSerialization.JSONObjectWithData(self, options: nil, error: &error) as? [AnyObject] {
            return json
        } else {
            println("Could not properly parse JSON data: \(error)")
            return nil
        }
    }

    internal func stringify(encoding: UInt = NSUTF8StringEncoding) -> String? {
        return NSString(data: self, encoding: encoding) as? String
    }

    internal func sign(algorithm: HMACAlgorithm, key: String) -> String? {
        let string = UnsafePointer<UInt8>(self.bytes)
        let stringLength = Int(self.length)
        let digestLength = algorithm.digestLength()
        
        if let keyString = key.cStringUsingEncoding(NSUTF8StringEncoding) {
            let keyLength = Int(key.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
            var result = [UInt8](count: digestLength, repeatedValue: 0)
            
            CCHmac(algorithm.toCCEnum(), keyString, keyLength, string, stringLength, &result)
            
            var hash: String = ""
            //for i in 0..<digestLength { hash += String(format: "%02x", result[i]) }
            var base64String: String = ""
            var binaryString: UInt32 = 0
            
            var mask: [Int: UInt32] = [
                0: 0b111111,
                6: 0b111111 << 6,
                12: 0b111111 << 12,
                18: 0b111111 << 18,
            ]
            
            var iteration = 0;
            
            for i in 0..<digestLength {
                
                binaryString <<= 8
                binaryString |= UInt32(result[i])
                
                iteration = i % 3
                
                if i % 3 == 2 {
                    var b1: Int = Int(binaryString & mask[18]!)
                    var b2: Int = Int(binaryString & mask[12]!)
                    var b3: Int = Int(binaryString & mask[6]!)
                    var b4: Int = Int(binaryString & mask[0]!)
                    
                    var ix1: Int = b1 >> 18
                    var ix2: Int = b2 >> 12
                    var ix3: Int = b3 >> 6
                    var ix4: Int = b4
                    
                    base64String.append(MIMEBase64Encoding[ix1])
                    base64String.append(MIMEBase64Encoding[ix2])
                    base64String.append(MIMEBase64Encoding[ix3])
                    base64String.append(MIMEBase64Encoding[ix4])
                    
                    binaryString = 0
                }
            }
            
            var padding = ""
            
            if binaryString > 0 {
                let remainder = Int(2 - iteration)
                
                
                for var j = 0; j < remainder; ++j {
                    padding += "="
                    binaryString <<= 2
                }
                
                for var k = 18 - (remainder * 6); k >= 0; k -= 6 {
                    var byte: Int = Int(binaryString & mask[k]!)
                    var index: Int = byte >> k
                    
                    base64String.append(MIMEBase64Encoding[index])
                }
                
                
            }
            return base64String + padding
        } else {
            return nil
        }
    }
}