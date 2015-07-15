//
//  HttpMultipartRequest.swift
//  Pods
//
//  Created by Kellan Cummings on 7/4/15.
//
//

import Foundation

internal class HttpMultipartRequest: HttpRequest {

    private var fileData: [String: NSData]
    
    private lazy var uniqueId: String = {
        return NSProcessInfo.processInfo().globallyUniqueString //"1234abcd"
        //String(format:"---------------------------%@", generateNonce(digits: 12))
    }()
    
    internal var boundary: String {
        return  "------WebKitFormBoundary\(uniqueId)"
    }

    init(URL: NSURL, data: [String: NSData], params: [String: AnyObject] = [String: AnyObject](), handler: NSData! -> Void = { data in }) {
        self.fileData = data
        
        super.init(URL: URL, method: HttpMethod.Post, params: params, handler: HttpRequest.getDefaultCompletionHandler(handler))

        self.headers = [
            "Content-Type": "\(HttpMediaType.MultipartFormData.description); boundary=\(boundary)",
            "Accept": HttpMediaType.Json.description
        ]
    }

    override func prepareBody(inout request: NSMutableURLRequest) {

        var postBody = NSMutableData()
        var postData = ""
        
        if parameters.count > 0 {
            postData += "--\(boundary)\r\n"
            for (key, value) in parameters {
                postData += "--\(boundary)\r\n"
                postData += "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
                postData += "\(value)\r\n"
            }
        }
        
        var fileNo = 0
        for (basename, data) in fileData {
            if let mediaType = MediaType.read(data) {
                //println("Setting \(mediaType.mimeType)")
                let currentDate = Int(NSDate().timeIntervalSince1970 * 1000)
                let name = "file\(fileNo)"
                let filename = "\(name)-\(uniqueId)"
                
                postData += "--\(boundary)\r\n"
                postData += "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename).\(mediaType.fileExtension)\"\r\n"
                postData += "Content-Type: \(mediaType.mimeType)\r\n\r\n"

                if let encodedData = postData.encode() {
                    postBody.appendData(encodedData)
                    postBody.appendData(data)
                    postData = "\r\n"

                } else {
                    postData = ""
                }

                ++fileNo
            } else {
                println("Unable to set media type!")
            }
        }

        postData += "\r\n--\(boundary)--\r\n"

        if let encodedData = postData.encode() {
            postBody.appendData(encodedData)
        }

        request.HTTPBody = NSData(data: postBody)
    }
}