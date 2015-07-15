//
//  Functions.swift
//  Pods
//
//  Created by Kellan Cummings on 6/10/15.
//
//

import Foundation
import Wildcard
import CommonCrypto

internal let MIMEBase64Encoding: [Character] = [
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
    "+", "/"
]

internal let WhitelistedPercentEncodingCharacters: [UnicodeScalar] = [
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
    ".", "-", "_", "~"
]


internal extension String {

    internal func sign(algorithm: HMACAlgorithm, key: String) -> String? {
        if let data = self.dataUsingEncoding(NSUTF8StringEncoding) {
            return data.sign(algorithm, key: key)
        }
        
        return nil
    }

    internal var base64Encoded: String {
        
        var encoded: String = ""
        var base: UInt64 = 0
        var i: UInt64 = 0
        var padding: String = ""
        
        for character in self.unicodeScalars {
            
            if i < 3 {
                base = base << 8 | UInt64(character)
                ++i
            } else {
                for i = 3; i > 0; --i {
                    let bitmask: UInt64 = 0b111111 << (i * 6)
                    encoded.append(
                        MIMEBase64Encoding[Int((bitmask & base) >> (i * 6))]
                    )
                }
                encoded.append(
                    MIMEBase64Encoding[Int(0b111111 & base)]
                )
                base = UInt64(character)
                i = 1
            }
        }
        
        let remainder = Int(3 - i)
        for var j = 0; j < remainder; ++j {
            padding += "="
            base <<= 2
        }
        
        let iterations: UInt64 = (remainder == 2) ? 1 : 2
        
        for var k: UInt64 = iterations ; k > 0; --k {
            let bitmask: UInt64 = 0b111111 << (k * 6)
            
            encoded.append(
                MIMEBase64Encoding[Int((bitmask & base) >> (k * 6))]
            )
        }
        
        encoded.append(
            MIMEBase64Encoding[Int(0b111111 & base)]
        )
        
        return encoded + padding
    }
    
    internal var urlEncoded: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
    }
    
    internal func percentEncode(ignore: [UnicodeScalar] = [UnicodeScalar]()) -> String {
        var output = ""
        
        for char in self.unicodeScalars {
            if contains(WhitelistedPercentEncodingCharacters, char) || contains(ignore, char) {
                output.append(char)
            } else {
                output += String(format: "%%%02X", UInt64(char))
            }
        }
        
        return output
    }
   
    internal func encode(encoding: UInt = NSUTF8StringEncoding, allowLossyConversion: Bool = true) -> NSData? {
        return self.dataUsingEncoding(encoding, allowLossyConversion: allowLossyConversion)
    }
}
