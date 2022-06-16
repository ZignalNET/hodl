//
//  Base.swift
//  Part of Hodl.
//
//  Created by Emmanuel Adigun on 2022/06/02. emmanuel@zignal.net
//  Copyright © 2022. All rights reserved.

import UIKit

typealias WebServiceCodableCallback<T: Codable>    = (T?, Error?)      -> Void
typealias WebServiceCallback                       = (Data?, Error?)   -> Void
typealias WebServiceCallbackValues                 = (Data?, Error?)
typealias AssetsBalances                           = [String:(Float,Float)]

public enum WebServiceError: Error {
    case invalidResponseCode(Int)
    case invalidResponseData(Data)
}

class Base {
    private(set) var name: String = ""
    private(set) var credentials: Auth = .none
    private(set) var urls: EndPoints = .UNDEFINED
    
    private let requestSessionConfig = URLSessionConfiguration.default
    private let requestSession       = URLSession(configuration: URLSessionConfiguration.default)
    private var requestTask: URLSessionDataTask?
    private var decoder = JSONDecoder()
    
    internal required init(_ name: String, _ auth: Auth = .none ) {
        self.name = name.uppercased()
        self.credentials = auth
        self.urls   = EndPoints(value: name)
        
        if auth == .none {
            if let apikey = hasApiKeys() {
                self.credentials = .basic(apikey.key, apikey.secret)
            }
        }
    }
    
    class var timestamp: Int {
        let nonce = Int(Date().timeIntervalSince1970 * 1000)
        return nonce
    }
    
    private func fetchURL(_ endpoint: (String,EndPoints.Method,String) ) -> ((String,String),Bool,EndPoints.Method) {
        let url    = (endpoint.0,endpoint.2)
        let auth   = self.credentials == Auth.none ? false : true
        let method = endpoint.1
        return (url,auth,method)
    }
    
    func setCredentials(_ credentials: Auth) {
        self.credentials = credentials
    }
    
    func getJSONDecoder() -> JSONDecoder { return decoder }
    
    func buildURL( _ endpoint: (String,EndPoints.Method,String) , _ parameters: [String:String] = [:] ) -> URLRequest {
        let (url,auth,method) = fetchURL( endpoint )
        var urlRequest = URLRequest(url: URL(string: url.0)!)
        if parameters.count > 0 {
            var p = URL(string: url.0)
            for (key,value) in parameters {
                p?.appendQueryItem(key, value)
            }
            urlRequest = URLRequest(url: p ?? URL(string: url.0)! )
        }
        urlRequest.httpMethod = method.rawValue
        if auth == true {
            signRequest(&urlRequest, (url,method))
        }
        return urlRequest
    }
    
    func signRequest( _ urlRequest: inout URLRequest, _ extra: ((String,String),EndPoints.Method)? = nil ) -> Void {
        fatalError("Must be overridden and implemented in derived class ...")
    }
    
    private func printResponseAsText(responseData: Data) {
        let text = NSString(data: responseData, encoding: String.Encoding.utf8.rawValue)
        debugPrint(text!)
    }
    
    func queueRequest<T: Codable>(_ urlRequest: URLRequest?, completion: WebServiceCodableCallback<T>? = nil  ) {
        if let requestURL = urlRequest {
            // Create Data Task
            requestTask = requestSession.dataTask(with: requestURL, completionHandler:
                {
                    (data, response, error) -> Void in
                    // check for any errors
                    guard error == nil else {
                        print("error calling URL \(String(describing: requestURL)) ")
                        completion?(nil,error)
                        return
                    }
                    // make sure we got response data
                    guard let responseData = data else {
                        print("Error: did not receive data")
                        completion?(nil,error)
                        return
                    }
                    
                    //Call handler if available
                    let statusCode = response?.value(forKey: "statusCode") as! Int
                    if statusCode == 200 {
                        do {
                            //self.printResponseAsText(responseData: responseData)
                            let obj = try self.decoder.decode(T.self, from: responseData)
                            completion?(obj,nil)
                        } catch let err {
                            print(#function, err)
                            completion?(nil,err)
                        }
                    }
                    else {
                        completion?(nil, WebServiceError.invalidResponseCode(statusCode))
                    }
                })
            requestTask?.resume()
        }
    }
    
    func queueRequest(_ urlRequest: URLRequest? ) -> WebServiceCallbackValues {
        var r: WebServiceCallbackValues?
        let semaphore = DispatchSemaphore(value: 0)
        if let requestURL = urlRequest {
            // Create Data Task
            requestTask = requestSession.dataTask(with: requestURL, completionHandler:
                {
                    (data, response, error) -> Void in
                    // check for any errors
                    guard error == nil else {
                        print("error calling URL \(String(describing: requestURL)) ")
                        r = (nil,error)
                        semaphore.signal()
                        return
                    }
                    // make sure we got response data
                    guard let responseData = data else {
                        print("Error: did not receive data")
                        r = (nil,error)
                        semaphore.signal()
                        return
                    }
                    
                    //Call handler if available
                    let statusCode = response?.value(forKey: "statusCode") as! Int
                    if statusCode == 200 {
                        //self.printResponseAsText(responseData: responseData)
                        r = (responseData,nil)
                    }
                    else {
                        r = (nil, WebServiceError.invalidResponseCode(statusCode))
                    }
                    semaphore.signal()
                })
            requestTask?.resume()
            semaphore.wait()
        }
        return r!
    }
    
    
    static func synchronousQuery(address: String) -> [String: Any]? {
        let url = URL(string: address)
        let semaphore = DispatchSemaphore(value: 0)
        
        var jsonData: [String: Any]? = nil
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            
            //Decode data
            if let responseData = data {
                do {
                    jsonData = try responseData.toDictionary()
                } catch let err {
                    print(#function, err)
                }
            }
            else if error != nil {
                print("error calling URL \(String(describing: address)) ")
                print(error!)
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        return jsonData
    }
    
    func fetchBalances(fiat: String) -> (Float,AssetsBalances?,Exchanges?) {
        fatalError("Must be overridden and implemented in derived class ...")
    }
    
}


extension Base {
    class func convertAssets(_ from: String, _ to: String, _ bMulti: Bool = true ) -> [String: Any]?{
        if bMulti { return Base.synchronousQuery(address: "\(EndPoints(value: "CONVERSION_MULTI").baseurl)?fsyms=\(from)&tsyms=\(to)") }
        else { return Base.synchronousQuery(address: "\(EndPoints(value: "CONVERSION_SINGLE").baseurl)?fsym=\(from)&tsyms=\(to)") }
    }
}

extension Base {
    func hasApiKeys() -> ApiKey? {
        if let apikey: ApiKey = KeyChainService.retrieveKey(self.name.uppercased()) { return apikey }
        return nil
    }
}


extension Base {

    func DarwinVersion() -> String {
        var sysinfo = utsname()
        uname(&sysinfo)
        let dv = String(bytes: Data(bytes: &sysinfo.release, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
        return "Darwin/\(dv)"
    }
    
    func CFNetworkVersion() -> String {
        let dictionary = Bundle(identifier: "com.apple.CFNetwork")?.infoDictionary!
        let version = dictionary?["CFBundleShortVersionString"] as! String
        return "CFNetwork/\(version)"
    }
    
    func deviceVersion() -> String {
        let currentDevice = UIDevice.current
        return "\(currentDevice.systemName)/\(currentDevice.systemVersion)"
    }
    
    func deviceName() -> String {
        var sysinfo = utsname()
        uname(&sysinfo)
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
    func appNameAndVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let name = dictionary["CFBundleName"] as! String
        return "\(name.capitalized(with: nil))/\(version)"
    }
    
    func UserAgentString() -> String {
        return "\(appNameAndVersion()) \(deviceName()) \(deviceVersion()) \(CFNetworkVersion()) \(DarwinVersion())"
    }
}
