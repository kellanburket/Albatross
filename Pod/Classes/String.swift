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

private let consonant = "[b-df-hj-np-tv-z]"
private let vowel = "[aeiou]"

let plurals: [(String, String)] = [
    ("(?<=f)oo(?=t)$|(?<=t)oo(?=th)$", "ee"),
    ("(?<=i)fe$|(?<=[eao]l)f$|(?<=(l|sh)ea)f$", "ves"),
    ("\\w{2,}[ie]x", "ices"),
    ("[ml]ouse$", "ice"),
    ("man$", "men"),
    ("child$", "children"),
    ("person$", "people"),
    ("eau$", "eaux"),
    ("(?<=-by)$", "s"),
    ("(?<=[^q]\(vowel)y)$", "s"),
    ("y$", "ies"),
    ("(?<=s|sh|tch)$", "es"),
    ("(?<=\(vowel)\(consonant)i)um", "a"),
    ("(?<=\\w)$", "s")
    //"a$": "ae",
    //"us$": "i"
    //"us$": "ora",
    //"us$": "era",
]

private let identicalPlurals: [String] = [
    "bison",
    "buffalo",
    "deer",
    "duck",
    "fish",
    "moose",
    "pike",
    "plankton",
    "salmon",
    "sheep",
    "squid",
    "swine",
    "trout",
    "beef",
    "wildlife",
    "golf"
]

private let irregularPlurals: [String:String] = [
    "potato": "potatoes",
    "die": "dice"
]

extension String {

    internal subscript(index: Int) -> String? {
        for (i, char) in enumerate(self) {
            if i == index {
                return String(char)
            }
        }

        return nil
    }
    
    public func toCamelcase() -> String {
        return self.gsub("_\\w") { match in
            return match[1]?.uppercaseString ?? match
        }
    }
    
    public func toSnakecase() -> String {
        return self.gsub("(\\p{L})") { match in
            return "_\(match.lowercaseString)"
        }
    }

    internal func sign(algorithm: HMACAlgorithm, key: String) -> String? {
        if let data = self.dataUsingEncoding(NSUTF8StringEncoding) {
            return data.sign(algorithm, key: key)
        }
        
        return nil
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
    
    public func repeat(times: Int) -> String {
        
        var rstring = ""
        if times > 0 {
            for i in 0...times {
                rstring = "\(rstring)\(self)"
            }
        }
        return rstring
    }
    
    public func pluralize(language: String = "en/us") -> String {
        if let plural = find(identicalPlurals, self) {
            return self
        }
        
        if let plural = irregularPlurals[self] {
            return plural
        }
        
        for (regex, mod) in plurals {
            var replacement = self.gsubi(regex, mod)
            if replacement != self {
                return replacement
            }
        }
        
        return self
    }

    
    /**
    Convert a string into an NSDate object. Currently supports both backslashes and hyphens in the following formats:
    
    * Y-m-d
    * m-d-Y
    * Y-n-j
    * n-j-Y
    
    :returns: a date
    */
    public func toDate() -> NSDate? {
        //println("to Date: \(self)")
        var patterns = [
            "(\\d{4})[-\\/](\\d{1,2})[-\\/](\\d{1,2})": ["year", "month", "day"],
            "(\\d{1,2})[-\\/](\\d{1,2})[-\\/](\\d{4})": ["month", "day", "year"]
        ]
        
        for (pattern, map) in patterns {
            if let matches = self.match(pattern) {
                //println("Matches \(matches)")
                if(matches.count == 4) {
                    var dictionary = [String:String]()
                    
                    for (i, item) in enumerate(map) {
                        dictionary[item] = matches[i + 1]
                    }
                    
                    let calendar = NSCalendar.currentCalendar()
                    let comp = NSDateComponents()
                    
                    if let year = dictionary["year"]?.toInt() {
                        comp.year = year
                        if let month = dictionary["month"]?.toInt() {
                            comp.month = month
                            if let day = dictionary["day"]?.toInt() {
                                comp.day = day
                                comp.hour = 0
                                comp.minute = 0
                                comp.second = 0
                                return calendar.dateFromComponents(comp)
                            }
                        }
                    }
                }
            }
        }
        return nil
    }

    /**
    Convert a string into an NSURL object.
    
    :return: if the string passed in
    */
    public func toUrl() -> NSURL? {
        return NSURL(string: self)
    }
    
    public func encode(encoding: UInt = NSUTF8StringEncoding, allowLossyConversion: Bool = true) -> NSData? {
        return self.dataUsingEncoding(encoding, allowLossyConversion: allowLossyConversion)
    }
    
    public var decapitalize: String {
        var prefix = self[startIndex..<advance(startIndex, 1)].lowercaseString
        var body = self[advance(startIndex, 1)..<endIndex]
        return "\(prefix)\(body)"
    }
}
