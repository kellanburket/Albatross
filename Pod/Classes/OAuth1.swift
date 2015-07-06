//
//  OAuth1Service.swift
//  Pods
//
//  Created by Kellan Cummings on 6/10/15.
//
//

import Foundation

protocol OAuth1Delegate {
    func accessTokenHasBeenFetched(accessToken: String, accessTokenSecret: String, username: String)
    func accessTokenHasExpired()
}

public class OAuth1: AuthorizationService {

    public var accessToken: String?
    public var accessTokenSecret: String?

    private var delegate: OAuth1Delegate?
    
    private var consumerSecret: String

    private var _requestTokenCallback: String
    private var _accessTokenUrl: NSURL
    private var _requestTokenUrl: NSURL
    private var _authorizeUrl: NSURL
    
    private var requestToken: String?
    private var requestTokenSecret: String?
    
    private var username: String?
    
    public var requestTokenUrl: NSURL {
        return _requestTokenUrl
    }

    public var accessTokenUrl: NSURL {
        return _accessTokenUrl
    }

    public var authorizeUrl: NSURL {
        return _authorizeUrl
    }

    public var requestTokenCallback: String {
        return _requestTokenCallback
    }
    
    private var signingKey: String? {
        if let secret = accessTokenSecret {
            return "\(consumerSecret.percentEncode())&\(secret.percentEncode())"
        }
        
        return nil
    }
    
    private var requestHeaders: [String: String]? {
        if let token = accessToken {
            return [
                "oauth_consumer_key": consumerKey,
                "oauth_token": token,
                "oauth_signature_method": "HMAC-SHA1",
                "oauth_timestamp": getCurrentTimestamp(),
                "oauth_nonce": generateNonce(),
                "oauth_version": "1.0"
            ]
        }
        return nil
    }

    private var requestTokenHeaders: [String: String] {
        return [
            "oauth_callback": requestTokenCallback,
            "oauth_consumer_key": consumerKey,
            "oauth_nonce": generateNonce(),
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_timestamp": getCurrentTimestamp(),
            "oauth_version": "1.0"
        ]
    }
    
    override public init(key: String, params: [String: AnyObject]) {
        
        if let consumerSecret = params["consumer_secret"] as? String {
            self.consumerSecret = consumerSecret
        } else {
            fatalError("Consumer Secret must be provided for OAuth1 Authentication")
        }

        if let requestTokenCallback = params["request_token_callback"] as? String {
            self._requestTokenCallback = requestTokenCallback
        } else {
            fatalError("Request Token Callback must be provided for OAuth1 Authentication")
        }

        if let requestTokenUrl = params["request_token_url"] as? String {
            self._requestTokenUrl = NSURL(string: requestTokenUrl)!
        } else {
            fatalError("Request Token URL must be provided for OAuth1 Authentication")
        }
        
        if let authorizeUrl = params["authorize_url"] as? String {
            self._authorizeUrl = NSURL(string: authorizeUrl)!
        } else {
            fatalError("Authorization URL must be provided for OAuth1 Authentication")
        }
        
        if let accessTokenUrl = params["access_token_url"] as? String {
            self._accessTokenUrl = NSURL(string: accessTokenUrl)!
        } else {
            fatalError("Access Token URL must be provided for OAuth1 Authentication")
        }
        
        if let accessToken = params["access_token"] as? String {
            self.accessToken = accessToken
        }
        
        if let accessTokenSecret = params["access_token_secret"] as? String {
            self.accessTokenSecret = accessTokenSecret
        }
        
        super.init(key: key, params: params)
    }

    override public func setSignature(url: NSURL, parameters: [String:AnyObject], method: String, onComplete: () -> ()) {
        //println("Setting Signature")
        headers = [String:String]()
        
        for (key, param) in parameters {
            if let pstring = param as? String {
                if pstring != "" {
                    headers[key] = pstring
                }
            } else {
                headers[key] = "\(param)"
            }
        }
        
        if let request = requestHeaders {
            headers += request
        }
        
        //println("Building Signature")
        var output = ""
        
        //println("Getting Header Keys")
        var keys = [String](headers.keys)
        
        //println("Sorting Header Keys")
        keys.sort { $0 < $1 }
        
        //println("Encoding Keys")
        for key in keys {
            if let header = headers[key] {
                output += (key.percentEncode() + "=" + "\(header)".percentEncode() + "&")
            } else {
                //println("Cannot Set \(key) for \(headers)")
            }
        }
        
        output = output.rtrim("&").percentEncode()
        var absoluteURL = url.absoluteString!.percentEncode()
        
        var signatureInput = "\(method)&\(absoluteURL)&\(output)"
        
        if let key = signingKey {
            if let signature = signatureInput.sign(HMACAlgorithm.SHA1, key: key) {
                self.headers["oauth_signature"] = signature
                onComplete()
            }
        } else {
            onComplete()
            println("Unable to Load Request Without Access Token")
        }
    }
    
    override public func setHeader(url: NSURL, inout request: NSMutableURLRequest) {
        var header: String = "OAuth realm=\"\(url.absoluteString!)\", "
        
        var keys = [String](headers.keys)
        keys.sort { return $0 < $1 }
        
        for key in keys {
            var akey = key.percentEncode()
            var aval = "\(headers[key]!)".percentEncode()
            header += "\(akey)=\"\(aval)\", "
        }
        
        header = header.rtrim(", ")
        //println("Header: \(header)")
        
        request.setValue(header, forHTTPHeaderField: "Authorization")
    }
    
    public func getRequestTokenURL(onComplete: NSURL? -> Void) {
        var requestHeaders: [String: String] = requestTokenHeaders
        
        var signingKey: String = consumerSecret.percentEncode() + "&"
        
        let request = HttpRequest(URL: requestTokenUrl, method: HttpMethod.Get, params: [String: AnyObject]()) { data, response, url in
            
            let query = HttpRequest.parseQuery(data, encoding: self.encoding)
            
            if query.count > 1 {
                self.requestToken = query["oauth_token"]
                self.requestTokenSecret = query["oauth_token_secret"]
                
                println("Request Token: \(self.requestToken)")
                println("Request Token Secret: \(self.requestTokenSecret)")
                
                if  let urlString = self.authorizeUrl.absoluteString,
                    let tokenString = self.requestToken,
                    let url = NSURL(string: "\(urlString)?oauth_token=\(tokenString)"
                ) {
                    onComplete(url)
                }
            } else {
                println("Unable to establish a connection with the server.")
                onComplete(nil)
            }
        }
        
        request.setHeaders(requestHeaders)
    }
    
    public func fetchAccessToken(#token: String, verifier: String, username: String = "") {
        self.username = username
        
        if let requestTokenSecret = requestTokenSecret {
            var signingKey: String = "\(consumerSecret.percentEncode())&\(requestTokenSecret.percentEncode())"
            
            let request = HttpRequest(URL: accessTokenUrl, method: HttpMethod.Get, params: [String: AnyObject]()) { data, response, url in
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                var parts = [String:String]()
                
                if let str = data.toString(encoding: self.encoding) {
                    var params = str.split("&")
                    
                    for param in params {
                        let values = param.split("=")
                        let key: String = values[0]
                        let value: String = values[1]
                        parts[key] = value
                    }


                    let query = HttpRequest.parseQuery(data, encoding: self.encoding)

                    println("\tQUERY: \(query)")
                    println("\tPARTS: \(parts)")

                    if let token = parts["oauth_token"] {
                        self.accessToken = token
                    }
                    
                    if let secret = parts["oauth_token_secret"] {
                        self.accessTokenSecret = secret
                    }
                    
                    if let delegate = self.delegate, token = self.accessToken, secret = self.accessTokenSecret, name = self.username {
                        delegate.accessTokenHasBeenFetched(token,
                            accessTokenSecret: secret,
                            username: name
                        )
                    } else {
                        println("Coult not parse query string: '\(str)'")
                    }
                } else {
                    println("Could not convert data to string")
                }
            }
            
            if let requestToken = requestToken {
                request.setHeaders([
                    "oauth_consumer_key": consumerKey,
                    "oauth_nonce": generateNonce(),
                    "oauth_timestamp": getCurrentTimestamp(),
                    "oauth_signature_method": "HMAC-SHA1",
                    "oauth_token": requestToken,
                    "oauth_verifier": verifier,
                    "oauth_version": "1.0"
                ])
            } else {
                println("Request Token not set.")
            }
            
            Http.post(request)
        } else {
            println("Request Token Secret not set.")
        }
    }
    
    public func fetchAccessToken(string: String) {
        var params = string.split("&");
        
        var identifiers = [String:String]()
        
        for param in params {
            var parts = param.split("=")
            var key = parts[0]
            identifiers[key] = parts[1]
        }
        
        fetchAccessToken(
            token: identifiers["oauth_token"]!,
            verifier: identifiers["oauth_verifier"]!,
            username: identifiers["username"]!
        )
    }
}
