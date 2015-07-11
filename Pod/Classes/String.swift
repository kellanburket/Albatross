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
    ("(\\w{2,})[ie]x", "$1ices"),
    ("(?<=[ml])ouse$", "ice"),
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

let singulars: [(String, String)] = [
    ("(?<=f)ee(?=t)$|(?<=t)ee(?=th)$", "oo"),
    ("(?<=i)ves$", "fe"),
    ("(?<=[eao]l)ves$|(?<=(l|sh)ea)ves$", "f"),
    ("(?<=[ml])ice$", "ouse"),
    ("men$", "man"),
    ("children$", "child"),
    ("people$", "person"),
    ("eaux$", "eau"),
    ("(?<=-by)s$", ""),
    ("(?<=[^q]\(vowel)y)s$", ""),
    ("ies$", "y"),
    ("(?<=s|sh|tch)es$", ""),
    ("(?<=\(vowel)\(consonant)i)a", "um"),
    ("(?<=\\w)s$", "")
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
    "die": "dice",
    "appendix": "appendices",
    "index": "indices",
    "matrix": "matrices",
    "radix": "radices",
    "vertex": "vertices",
    "radius": "radii"
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
    
    public func singularize(language: String = "en/us") -> String {
        if let singular = find(identicalPlurals, self) {
            return self
        }

        if let plurals = irregularPlurals.flip(), plural = plurals[self] {
            return plural
        }

        for (regex, mod) in singulars {
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
            "\\w+ (\\w+) (\\d+) (\\d{1,2}):(\\d{1,2}):(\\d{1,2}) \\+\\d{4} (\\d{4})": ["month", "day", "hour", "minute", "second", "year"],
            "(\\d{4})[-\\/](\\d{1,2})[-\\/](\\d{1,2})(?: (\\d{1,2}):(\\d{1,2}):(\\d{1,2}))?": ["year", "month", "day", "hour", "minute", "second"],
            "(\\d{1,2})[-\\/](\\d{1,2})[-\\/](\\d{4})(?: (\\d{1,2}):(\\d{1,2}):(\\d{1,2}))?": ["month", "day", "year", "hour", "minute", "second"]
        ]
        
        for (pattern, map) in patterns {
            if let matches = self.match(pattern) {
                //println("Matches \(matches)")
                if(matches.count >= 4) {
                    var dictionary = [String:String]()

                    for (i, item) in enumerate(map) {
                        if i + 1 < matches.count {
                            dictionary[item] = matches[i + 1]
                        } else {
                            break
                        }
                    }
                    
                    let calendar = NSCalendar.currentCalendar()
                    let comp = NSDateComponents()

                    comp.year = 0
                    if let year = dictionary["year"]?.toInt() {
                        comp.year = year
                    }
                    
                    comp.month = 0
                    if let month = dictionary["month"] {
                        if let month = month.toInt() {
                            comp.month = month
                        } else {
                            var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
                            for (i, m) in enumerate(months) {
                                if month =~ m {
                                    comp.month = i
                                    break
                                }
                            }
                        }
                    }
                    
                    comp.day = 0
                    if let day = dictionary["day"]?.toInt() {
                        comp.day = day
                    }
                    
                    comp.hour = 0
                    if let hour = dictionary["hour"]?.toInt() {
                        comp.hour = hour
                    }
                    
                    comp.minute = 0
                    if let minute = dictionary["minute"]?.toInt() {
                        comp.minute = minute
                    }
                    
                    comp.second = 0
                    if let second = dictionary["second"]?.toInt() {
                        comp.second = second
                    }

                    return calendar.dateFromComponents(comp)
                }
            }
        }
        return nil
    }

    /*
    public var hex: UInt64? {
        if self =~ "^[0-9a-fA-F]+$" {
            var total = 0
            let length = count(self)
            for (i, char) in enumerate(self.unicodeScalars) {
                var temp = 0
        
                switch String(char).uppercaseString {
                    case "1": temp = 1
                    case "2": temp = 2
                    case "3": temp = 3
                    case "4": temp = 4
                    case "5": temp = 5
                    case "6": temp = 6
                    case "7": temp = 7
                    case "8": temp = 8
                    case "9": temp = 9
                    case "A": temp = 10
                    case "B": temp = 11
                    case "C": temp = 12
                    case "D": temp = 13
                    case "E": temp = 14
                    case "F": temp = 15
                    default: temp = 0
                }
            
                total += temp * (2 << (length - 1))
            }
            
            return total
        }
        
        return nil
    }
    */
    
    public func encode(encoding: UInt = NSUTF8StringEncoding, allowLossyConversion: Bool = true) -> NSData? {
        return self.dataUsingEncoding(encoding, allowLossyConversion: allowLossyConversion)
    }
    
    public func decapitalize() -> String {
        var prefix = self[startIndex..<advance(startIndex, 1)].lowercaseString
        var body = self[advance(startIndex, 1)..<endIndex]
        return "\(prefix)\(body)"
    }

    public func capitalize() -> String {
        var prefix = self[startIndex..<advance(startIndex, 1)].uppercaseString
        var body = self[advance(startIndex, 1)..<endIndex]
        return "\(prefix)\(body)"
    }

}
