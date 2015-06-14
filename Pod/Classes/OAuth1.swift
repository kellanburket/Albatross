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

public class OAuth1: AuthenticationService {
    
    private var delegate: OAuth1Delegate?
    
    private var consumerKey: String = ""
    private var consumerSecret: String = ""

    private var requestTokenCallback: String = ""
    private var accessTokenUrl: NSURL?
    private var requestTokenUrl: NSURL?
    private var authorizeUrl: NSURL?
    
    private var requestToken: String?
    private var requestTokenSecret: String?
    
    private var accessToken: String = ""
    private var accessTokenSecret: String = ""
    
    private var username: String?
    
    private var signingKey: String {
        return "\(consumerSecret.percentEncode())&\(accessTokenSecret.percentEncode())"
    }

    override public init(_ args: NSDictionary) {
        println(args);
        if let consumerKey = args["consumer_key"] as? String {
            self.consumerKey = consumerKey
        }

        if let consumerSecret = args["consumer_secret"] as? String {
            self.consumerSecret = consumerSecret
        }

        if let requestTokenCallback = args["request_token_callback"] as? String {
            self.requestTokenCallback = requestTokenCallback
        }

        if let requestTokenUrl = args["request_token_url"] as? String {
            self.requestTokenUrl = NSURL(string: requestTokenUrl)!
        }
        
        if let authorizeUrl = args["authorize_url"] as? String {
            self.authorizeUrl = NSURL(string: authorizeUrl)!
        }
        
        if let accessTokenUrl = args["access_token_url"] as? String {
            self.accessTokenUrl = NSURL(string: accessTokenUrl)!
        }
        
        super.init(args)
    }

    override public func setSignature(url: NSURL, parameters: [String:AnyObject], method: String, inout headers: [String:String]) {

        var oAuthHeaders = parameters + headers
        
        var newParams = [String:AnyObject]()
        
        for (key, param) in parameters {
            if let pstring = param as? String {
                if pstring != "" {
                    newParams[key] = pstring
                }
            } else {
                newParams[key] = param
            }
        }
        
        headers["oauth_signature"] = OAuth1.buildSignature(
            url,
            params: oAuthHeaders,
            signingKey: signingKey,
            method: method
        )!
        
        self.headers = headers
    }
    
    override public func setHeader(url: NSURL, parameters: [String: AnyObject], inout request: NSMutableURLRequest) {
        var header: String = "OAuth realm=\"\(url.absoluteString!)\", "
        
        var keys = [String](parameters.keys)
        keys.sort { return $0 < $1 }
        
        for key in keys {
            var akey = key.percentEncode()
            var aval = "\(parameters[key]!)".percentEncode()
            header += "\(akey)=\"\(aval)\", "
        }
        
        request.setValue(header.rtrim(", "), forHTTPHeaderField: "Authorization")
    }

    func setAccessToken(accessToken: String, accessTokenSecret: String, username: String) {
        self.accessToken = accessToken
        self.username = username
        self.accessTokenSecret = accessTokenSecret
    }

    class func buildSignature(URL: NSURL, params: [String:AnyObject], signingKey: String, method: String) -> String? {
        var output = ""
        
        var keys = [String](params.keys)
        
        keys.sort({ return $0 < $1 })
        
        for key in keys {
            output += (key.percentEncode() + "=" + "\(params[key]!)".percentEncode() + "&")
        }
        
        output = output.rtrim("&").percentEncode()
        var absoluteURL = URL.absoluteString!.percentEncode()
        
        var signatureInput = "\(method)&\(absoluteURL)&\(output)"
        
        return signatureInput.sign(HMACAlgorithm.SHA1, key: signingKey)
    }
    
    func fetchAccessToken(#token: String, verifier: String, username: String = "") {
        self.username = username
        
        var signingKey: String = "\(consumerSecret.percentEncode())&\(requestTokenSecret!.percentEncode())"
        
        if let url = accessTokenUrl {
            
            let request = HttpRequest(URL: url) { data in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                var parts = [String:String]()
                
                let params = String(NSString(data: data!, encoding: self.encoding)!).split("&")

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
                
                if let delegate = self.delegate {
                    delegate.accessTokenHasBeenFetched(
                        self.accessToken,
                        accessTokenSecret: self.accessTokenSecret,
                        username: self.username!
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
    
    func getRequestTokenURL(onComplete: (NSURL) -> ()) {
        var requestHeaders: [String: String] = [
            "oauth_callback": requestTokenCallback,
            "oauth_consumer_key": consumerKey,
            "oauth_nonce": generateNonce(),
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_timestamp": getCurrentTimestamp(),
            "oauth_version": "1.0"
        ]
        
        var signingKey: String = consumerSecret.percentEncode() + "&"
        
        if let url = requestTokenUrl {
            
            let request = HttpRequest(URL: url) { data in
                
                let query = HttpRequest.parseQuery(data, encoding: self.encoding)
                
                if query.count > 1 {
                    self.requestToken = query["oauth_token"]
                    self.requestTokenSecret = query["oauth_token_secret"]
                    
                    println("Request Token: \(self.requestToken)")
                    println("Request Token Secret: \(self.requestTokenSecret)")
                    
                    if let urlString = self.authorizeUrl?.absoluteString, let tokenString = self.requestToken, let url = NSURL(string: "\(urlString)?oauth_token=\(tokenString)") {
                        onComplete(url)
                    }
                } else {
                    //AlertDialogueController("Error", "Purlie was unable to establish a connection with the server.").present()
                }
            }
            request.setHeaders(requestHeaders)
        }
        
    }
        
    func getRequestHeaders() -> [String: AnyObject] {
        return [
            "oauth_consumer_key": consumerKey,
            "oauth_token": accessToken,
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_timestamp": getCurrentTimestamp(),
            "oauth_nonce": generateNonce(),
            "oauth_version": "1.0"
        ]
    }
}
