//
//  Functions.swift
//  Pods
//
//  Created by Kellan Cummings on 6/10/15.
//
//

import Foundation
import Wildcard

public let MIMEBase64Encoding: [Character] = [
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
    "+", "/"
]

public let WhitelistedPercentEncodingCharacters: [UnicodeScalar] = [
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
    ".", "-", "_", "~"
]

extension String {

    func toCamelcase() {
        self.gsub("_(\\w)") { match in
            return match.uppercaseString
        }
    }
    
    func toSnakecase() {
        self.gsub("(\\p{L})") { match in
            return "_\(match.lowercaseString)"
        }
    }

    public var base64Encoded: String {
        
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
    
    public var urlEncoded: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
    }
    
    public func percentEncode(ignore: [UnicodeScalar] = [UnicodeScalar]()) -> String {
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
    
    func repeat(times: Int) -> String {
        
        var rstring = ""
        if times > 0 {
            for i in 0...times {
                rstring = "\(rstring)\(self)"
            }
        }
        return rstring
    }
    
    /**
    Convert a string into an NSURL object.
    
    :return: if the string passed in
    */
    func toUrl() -> NSURL? {
        return NSURL(string: self)
    }
}
