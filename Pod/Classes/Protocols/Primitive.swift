//
//  Primitive.swift
//  Pods
//
//  Created by Kellan Cummings on 7/11/15.
//
//

import Foundation

protocol Primitive {}

extension String: Primitive {}
extension Character: Primitive {}
extension Int: Primitive {}
extension UInt: Primitive {}
extension Int8: Primitive {}
extension UInt8: Primitive {}
extension Int16: Primitive {}
extension UInt16: Primitive {}
extension Int32: Primitive {}
extension UInt32: Primitive {}
extension Int64: Primitive {}
extension UInt64: Primitive {}
extension Float: Primitive {}
extension Double: Primitive {}
extension Bool: Primitive {}