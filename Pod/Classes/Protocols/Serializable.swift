//
//  Serializable.swift
//  Pods
//
//  Created by Kellan Cummings on 7/6/15.
//
//

import Foundation

internal protocol Serializable {
    func __prepare() -> String
}

extension String: Serializable {
    func __prepare() -> String {
        return self
    }
}

extension Character: Serializable {
    func __prepare() -> String {
        return "\(self)"
    }
}

extension Int: Serializable {
    func __prepare() -> String {
        return "\(self)"
    }
}

extension UInt: Serializable {
    func __prepare() -> String {
        return "\(self)"
    }
}

extension Int8: Serializable {
    func __prepare() -> String {
        return "\(self)"
    }
}

extension UInt8: Serializable {
    func __prepare() -> String {
        return "\(self)"
    }
}

extension Int16: Serializable {
    func __prepare() -> String {
        return "\(self)"
    }
}

extension UInt16: Serializable {
    func __prepare() -> String {
        return "\(self)"
    }
}

extension Int32: Serializable {
    func __prepare() -> String {
        return "\(self)"
    }
}

extension UInt32: Serializable {
    func __prepare() -> String {
        return "\(self)"
    }
}

extension Int64: Serializable {
    func __prepare() -> String {
        return "\(self)"
    }
}

extension UInt64: Serializable {
    func __prepare() -> String {
        return "\(self)"
    }
}

extension Float: Serializable {
    func __prepare() -> String {
        return "\(self)"
    }
}

extension Double: Serializable {
    func __prepare() -> String {
        return "\(self)"
    }
}

extension Bool: Serializable {
    func __prepare() -> String {
        return "\(self)"
    }
}

extension NSURL: Serializable {
    func __prepare() -> String {
        return self.absoluteString ?? ""
    }
}

extension NSAttributedString: Serializable {
    func __prepare() -> String {
        return self.string
    }
}

extension UIColor: Serializable {
    func __prepare() -> String {
        //TODO Convert to Hex
        return ""
    }
}

extension NSDate: Serializable {
    func __prepare() -> String {
        return self.format("yyyy-MM-dd hh:ii:ss")
    }
}
