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
    
    private var delegate: OAuth1Delegate?
    
    private var consumerKey: String
    private var consumerSecret: String

    private var requestTokenCallback: String
    private var accessTokenUrl: NSURL
    private var requestTokenUrl: NSURL
    private var authorizeUrl: NSURL
    
    private var requestToken: String?
    private var requestTokenSecret: String?
    
    private var accessToken: String?
    private var accessTokenSecret: String?
    
    private var username: String?
    
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

    override public init(_ args: NSDictionary) {
        
        if let consumerKey = args["consumer_key"] as? String {
            self.consumerKey = consumerKey
        } else {
            fatalError("Consumer Key must be provided for OAuth1 Authentication")
        }

        if let consumerSecret = args["consumer_secret"] as? String {
            self.consumerSecret = consumerSecret
        } else {
            fatalError("Consumer Secret must be provided for OAuth1 Authentication")
        }

        if let requestTokenCallback = args["request_token_callback"] as? String {
            self.requestTokenCallback = requestTokenCallback
        } else {
            fatalError("Request Token Callback must be provided for OAuth1 Authentication")
        }

        if let requestTokenUrl = args["request_token_url"] as? String {
            self.requestTokenUrl = NSURL(string: requestTokenUrl)!
        } else {
            fatalError("Request Token URL must be provided for OAuth1 Authentication")
        }
        
        if let authorizeUrl = args["authorize_url"] as? String {
            self.authorizeUrl = NSURL(string: authorizeUrl)!
        } else {
            fatalError("Authorization URL must be provided for OAuth1 Authentication")
        }
        
        if let accessTokenUrl = args["access_token_url"] as? String {
            self.accessTokenUrl = NSURL(string: accessTokenUrl)!
        } else {
            fatalError("Access Token URL must be provided for OAuth1 Authentication")
        }
        
        if let accessToken = args["access_token"] as? String {
            self.accessToken = accessToken
        }
        
        if let accessTokenSecret = args["access_token_secret"] as? String {
            self.accessTokenSecret = accessTokenSecret
        }
        
        super.init(args)
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
        
        buildSignature(url, method: method) { signature in
            self.headers["oauth_signature"] = signature
            //println("Headers: \(self.headers)")
            onComplete()
        }
    }

    func buildSignature(URL: NSURL, method: String, onComplete: (String) -> ()) {
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
        var absoluteURL = URL.absoluteString!.percentEncode()
        
        var signatureInput = "\(method)&\(absoluteURL)&\(output)"
        
        if let key = signingKey {
            if let input = signatureInput.sign(HMACAlgorithm.SHA1, key: key) {
                onComplete(input)
            }
        } else {
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

    func setAccessToken(accessToken: String, accessTokenSecret: String, username: String) {
        self.accessToken = accessToken
        self.username = username
        self.accessTokenSecret = accessTokenSecret
    }
    
    private func getRequestTokenURL(onComplete: (NSURL) -> ()) {
        var requestHeaders: [String: String] = [
            "oauth_callback": requestTokenCallback,
            "oauth_consumer_key": consumerKey,
            "oauth_nonce": generateNonce(),
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_timestamp": getCurrentTimestamp(),
            "oauth_version": "1.0"
        ]
        
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
                //AlertDialogueController("Error", "Purlie was unable to establish a connection with the server.").present()
            }
        }
        
        request.setHeaders(requestHeaders)
    }
    
    private func fetchAccessToken(#token: String, verifier: String, username: String = "") {
        self.username = username
        
        var signingKey: String = "\(consumerSecret.percentEncode())&\(requestTokenSecret!.percentEncode())"
        
        let request = HttpRequest(URL: accessTokenUrl, method: HttpMethod.Get, params: [String: AnyObject]()) { data, response, url in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            var parts = [String:String]()
            
            let params = String(NSString(data: data, encoding: self.encoding)!).split("&")

            for param in params {
                let values = param.split("=")
                let key: String = values[0]
                let value: String = values[1]
                parts[key] = value
            }
            
            let query = HttpRequest.parseQuery(data, encoding: self.encoding)
            
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
            }
        }
        
        request.setHeaders([
            "oauth_consumer_key": consumerKey,
            "oauth_nonce": generateNonce(),
            "oauth_timestamp": getCurrentTimestamp(),
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_token": self.requestToken!, //token,
            "oauth_verifier": verifier,
            "oauth_version": "1.0"
        ])
        
        Http.post(request)
    }
    
    func fetchAccessToken(string: String) {
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
