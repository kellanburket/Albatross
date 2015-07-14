//
//  OAuth1Service.swift
//  Pods
//
//  Created by Kellan Cummings on 6/10/15.
//
//

import Foundation

public class OAuth1: AuthenticationService {

    public var token: String?
    public var secret: String?
    public var delegate: OAuth1Delegate?
    
    private var consumerSecret: String

    private var _requestTokenCallback: String
    private var _accessTokenUrl: NSURL
    private var _requestTokenUrl: NSURL
    private var _authorizeUrl: NSURL
    
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
    
    private var signingKey: String {
        var secret = self.secret?.percentEncode() ?? ""
        return "\(consumerSecret.percentEncode())&\(secret)"
    }
    
    private var requestHeaders: [String: String] {
        var params = [
            "oauth_consumer_key": consumerKey,
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_timestamp": getCurrentTimestamp(),
            "oauth_nonce": generateNonce(),
            "oauth_version": "1.0"
        ]
        
        if let token = token {
            params["oauth_token"] = token
        }

        return params
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
        
        if let token = params["token"] as? String {
            self.token = token
        }
        
        if let secret = params["secret"] as? String {
            self.secret = secret
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
        
        headers += requestHeaders
        
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
        
         if let signature = signatureInput.sign(HMACAlgorithm.SHA1, key: signingKey) {
            self.headers["oauth_signature"] = signature
            onComplete()
        }
    }
    
    override public func setHeader(url: NSURL, inout request: NSMutableURLRequest) {
        var header: String = "OAuth "//realm=\"\(url.absoluteString!)\", "
        
        var keys = [String](headers.keys)
        keys.sort { return $0 < $1 }
        
        for key in keys {
            var akey = key.percentEncode()
            var aval = "\(headers[key]!)".percentEncode()
            header += "\(akey)=\"\(aval)\", "
        }
        
        header = header.rtrim(", ")
        println("Header: \(header)")
        
        request.setValue(header, forHTTPHeaderField: "Authorization")
    }
    
    public func getRequestTokenURL(onComplete: (String?, NSURL?) -> Void) {
        
        let request = HttpRequest(URL: requestTokenUrl, method: HttpMethod.Post, params: Json()) { data, response, url in
            
            let query = HttpRequest.parseQueryString(data, encoding: self.encoding)
            if let requestToken = query["oauth_token"] as? String, requestTokenSecret = query["oauth_token_secret"] as? String {
            
                println("Request Token: \(requestToken)")
                println("Request Token Secret: \(requestTokenSecret)")
                self.secret = requestTokenSecret
                self.token = requestToken
                
                if let baseurl = self.authorizeUrl.absoluteString, url = NSURL(string: "\(baseurl)?oauth_token=\(requestToken)") {
                    onComplete(requestTokenSecret, url)
                } else {
                    println("Could not parse URL string.")
                    onComplete(nil, nil)
                }
            } else {
                println("Was unable to fetch Request Token.")
                onComplete(nil, nil)
            }
        }

        request.authenticate(
            OAuth1RequestToken(key: consumerKey, params: [
                "consumer_secret": consumerSecret,
                "request_token_callback": requestTokenCallback,
                "request_token_url": requestTokenUrl.absoluteString!,
                "authorize_url": authorizeUrl.absoluteString!,
                "access_token_url": accessTokenUrl.absoluteString!
            ])
        )

        Http.start(request)
    }
    
    public func fetchAccessToken(#token: String, verifier: String) {
        
        let request = HttpRequest(URL: accessTokenUrl, method: HttpMethod.Get, params: [String: AnyObject]()) { data, response, url in
            
            let query = HttpRequest.parseQueryString(data, encoding: self.encoding)

            if let token = query["oauth_token"] as? String, secret = query["oauth_token_secret"] as? String {
                self.token = token
                self.secret = secret
                
                if let delegate = self.delegate {
                    delegate.accessTokenHasBeenFetched(token,
                        accessTokenSecret: secret
                    )
                }
                
            } else {
                println("Could not parse query string \(query).")
            }
        }

        if let secret = self.secret {
            request.authenticate(
                OAuth1AccessToken(key: consumerKey, params: [
                    "consumer_secret": consumerSecret,
                    "request_token_callback": requestTokenCallback,
                    "request_token_url": requestTokenUrl.absoluteString!,
                    "authorize_url": authorizeUrl.absoluteString!,
                    "access_token_url": accessTokenUrl.absoluteString!,
                    "secret": secret,
                    "token": token,
                    "verifier": verifier
                ])
            )
            Http.post(request)
        } else {
            println("Could Not Authorize without secret.")
        }
    }
}

private class OAuth1RequestToken: OAuth1 {
    
    override private var requestHeaders: [String: String] {
        return [
            "oauth_callback": requestTokenCallback,
            "oauth_consumer_key": consumerKey,
            "oauth_nonce": generateNonce(),
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_timestamp": getCurrentTimestamp(),
            "oauth_version": "1.0"
        ]
    }
}

private class OAuth1AccessToken: OAuth1 {

    var verifier: String

    override private var requestHeaders: [String: String] {
        if let token = token {
            return [
                "oauth_consumer_key": consumerKey,
                "oauth_nonce": generateNonce(),
                "oauth_timestamp": getCurrentTimestamp(),
                "oauth_signature_method": "HMAC-SHA1",
                "oauth_token": token,
                "oauth_verifier": verifier,
                "oauth_version": "1.0"
            ]
        } else {
            println("Unable to find required token.")
            return [String: String]()
        }
    }
    
    override init(key: String, params: [String: AnyObject]) {
        if let verifier = params["verifier"] as? String {
            self.verifier = verifier
        } else {
            fatalError("Must Provide a verifier to fetch an access token.")
        }

        super.init(key: key, params: params)
    }
}