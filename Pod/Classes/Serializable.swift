//
//  Serializable.swift
//  Pods
//
//  Created by Kellan Cummings on 7/6/15.
//
//

import Foundation

protocol Serializable {}

extension String: Serializable {}
extension Int: Serializable {}
extension UInt: Serializable {}
extension Int8: Serializable {}
extension UInt8: Serializable {}
extension Int16: Serializable {}
extension UInt16: Serializable {}
extension Int32: Serializable {}
extension UInt32: Serializable {}
extension Int64: Serializable {}
extension UInt64: Serializable {}
extension Float: Serializable {}
extension Double: Serializable {}
extension Bool: Serializable {}