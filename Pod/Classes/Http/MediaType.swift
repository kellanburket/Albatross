//
//  MediaType.swift
//  Pods
//
//  Created by Kellan Cummings on 7/4/15.
//
//

import Foundation

internal enum MediaType: UInt8 {
    case JPG = 0xFF
    case GIF = 0x47
    case PNG = 0x89
    case TIFF = 0x4D
    case PDF = 0x25
    
    static func read(data: NSData) -> MediaType? {
        var bytes = [UInt8](count: 1, repeatedValue: 0)
        data.getBytes(&bytes, length: 1)
        let byte = String(bytes[0], radix: 16)
        //println("Byte[0]: \(byte)")
        return MediaType(rawValue: bytes[0])
    }
    
    var mimeType: String {
        return "\(self.basetype)/\(self.subtype)"
    }

    var subtype: String {
        switch self {
            case JPG:
                return "jpeg"
            default:
                return self.fileExtension
        }
    }
    
    var basetype: String {
        switch self {
            case JPG, GIF, PNG, TIFF:
                return "image"
            case PDF:
                return "application"
        }
    }
    
    var fileExtension: String {
        switch self {
            case JPG: return "jpg"
            case GIF: return "gif"
            case PNG: return "png"
            case TIFF: return "tiff"
            case PDF: return "pdf"
        }
    }
}