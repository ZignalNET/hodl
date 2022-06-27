//
//  Base.swift
//  Part of Hodl.
//
//  Created by Emmanuel Adigun on 2022/06/02. emmanuel@zignal.net
//  Copyright © 2022. All rights reserved.

import UIKit
import Starscream

typealias WebServiceCodableCallback<T: Codable>    = (T?, Error?)      -> Void
typealias WebServiceCallback                       = (Data?, Error?)   -> Void
typealias WebServiceCallbackValues                 = (Data?, Error?)
typealias AssetsBalances                           = [String:(Float,Float)]
typealias PendingOrder                             = (String,String,String,String,String)
typealias PendingOrders                            = [PendingOrder]

public enum WebServiceError: Error {
    case invalidResponse(URLResponse)
    case invalidResponseCode(Int)
    case invalidResponseData(Data)
}

protocol BaseMethods {
    func fetchBalances(fiat: String) -> (Float,AssetsBalances?,Exchanges?)
    func fetchPendingOrders() -> [PendingOrder]
}

let BaseInstance = Base(.none)

@objc(Base)
class Base: NSObject, BaseMethods, WebSocketDelegate {
    private(set) var name: String = ""
    private(set) var credentials: Auth = .none
    private(set) var urls: EndPoints = .UNDEFINED
    
    private let requestSessionConfig = URLSessionConfiguration.default
    private let requestSession       = URLSession(configuration: URLSessionConfiguration.default)
    private var requestTask: URLSessionDataTask?
    private var decoder = JSONDecoder()
    
    private var webSocket: WebSocket?
    private(set) var isConnectedToWebSocket = false
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale.current
        return formatter
    }()
    
    private override init() {
        super.init()
    }
    
    internal required init(_ auth: Auth = .none ) {
        super.init()
        self.name = NSStringFromClass(type(of: self)).uppercased()
        self.credentials = auth
        self.urls   = EndPoints(value: name)
        
        if auth == .none {
            if let apikey = hasApiKeys() {
                setCredentials(key: apikey)
                openWebSocket() // but dont connect yet!
            }
        }
    }
    
    class var timestamp: Int {
        let nonce = Int(Date().timeIntervalSince1970 * 1000)
        return nonce
    }
    
    private func fetchURL(_ endpoint: EndPoint ) -> ((String,String),Bool,EndPoints.Method) {
        let url    = (endpoint.0,endpoint.2)
        let auth   = self.credentials == Auth.none ? false : true
        let method = endpoint.1
        return (url,auth,method)
    }
    
    func setCredentials(_ credentials: Auth) {
        self.credentials = credentials
    }
    
    func setCredentials(key: ApiKey) {
        
    }
    
    func getJSONDecoder() -> JSONDecoder { return decoder }
    
    func buildURL( _ endpoint: EndPoint , _ parameters: [String:String] = [:] ) -> URLRequest {
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
    
    func validateResponse(_ response: URLResponse?) -> Bool {
        guard let r = response as? HTTPURLResponse, r.statusCode == 200 else { return false }
        return true
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
                    guard error == nil else { completion?(nil,error); return }
                    if self.validateResponse(response) { //check for 200.. derived class should check for 429 etc ...
                        // make sure we got response data
                        guard let responseData = data else { completion?(nil,error); return }
                        //self.printResponseAsText(responseData: responseData)
                        //print( requestURL.description )
                        do {
                            let obj = try self.decoder.decode(T.self, from: responseData)
                            completion?(obj,nil)
                        } catch let err {
                            print(#function, err)
                            completion?(nil,err)
                        }
                    }
                    else {
                        completion?(nil, WebServiceError.invalidResponse(response!))
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
                    guard error == nil else { r = (nil,error);semaphore.signal();return}
                    if self.validateResponse(response) { //check for 200.. derived class should check for 429 etc ...
                        // make sure we got response data
                        guard let responseData = data else {r = (nil,error);return}
                        r = (responseData,nil)
                    }
                    else {
                        r = (nil, WebServiceError.invalidResponse(response!))
                    }
                    semaphore.signal()
                })
            requestTask?.resume()
            semaphore.wait()
        }
        return r!
    }
    
    
    func synchronousQuery(address: String) -> [String: Any]? {
        let url = URL(string: address)
        let semaphore = DispatchSemaphore(value: 0)
        
        var jsonData: [String: Any]? = nil
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            guard error == nil else { semaphore.signal();return}
            if self.validateResponse(response) { //check for 200.. derived class should check for 429 etc ...
                //Decode data
                if let responseData = data {
                    do {
                        jsonData = try responseData.toDictionary()
                    } catch let err {
                        print(#function, err)
                    }
                }
            }
            else {
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
    
    func fetchPendingOrders() -> [PendingOrder] {
        fatalError("Must be overridden and implemented in derived class ...")
    }
    
    func sendWebSocketCredentials(_ client: WebSocket) {
       
    }
    
    private func openWebSocket() {
        if let url = URL(string: self.urls.streams) {
            var request = URLRequest(url: url)
            request.timeoutInterval = 5
            webSocket = WebSocket(request: request)
        }
    }
    
    func connectToWebSocket() {
        if let webSocket = webSocket {
            webSocket.delegate = self
            webSocket.connect()
        }
    }
    
}


extension Base {
    class func convertAssets(_ from: String, _ to: String, _ bMulti: Bool = true ) -> [String: Any]?{
        if bMulti { return BaseInstance.synchronousQuery(address: "\(EndPoints(value: "CONVERSION_MULTI").baseurl)?fsyms=\(from)&tsyms=\(to)") }
        else { return BaseInstance.synchronousQuery(address: "\(EndPoints(value: "CONVERSION_SINGLE").baseurl)?fsym=\(from)&tsyms=\(to)") }
    }
}

extension Base {
    func hasApiKeys() -> ApiKey? {
        if let apikey: ApiKey = KeyChainService.retrieveKey(self.name.uppercased()) { return apikey }
        return nil
    }
}

extension Base {
    class func convetAssetBalancesToLocal(base: String, assets:[String], assetbalances: AssetsBalances) -> (Float,AssetsBalances) {
        var total: Float = 0.0
        let assetList = assets.joined(separator: ",")
        var balances: AssetsBalances = assetbalances
        //print(assetList,base)
        if assetList.count > 0, let data = Base.convertAssets(assetList,base) {
            if let b = balances[base] { total += b.0 }
            for d in data {
                let key = d.key
                if let value = d.value as? Dictionary<String,NSNumber> {
                    if let rate = value[base] {
                        if let balance = balances[key] {
                            let t = balance.0
                            balances[key]?.1 = t * rate.floatValue
                            total += balances[key]!.1
                        }
                    }
                }
            }
        }
        return ( total, balances )
    }
}


extension Base {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnectedToWebSocket = true
            sendWebSocketCredentials(client)
            onConnect(headers)
        case .disconnected(let reason, let code):
            isConnectedToWebSocket = false
            onDisConnect(reason, code)
        case .text(let string):
            onReceivedText(string)
        case .binary(let data):
            onReceivedData(data)
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnectedToWebSocket = false
            break
        case .error(let error):
            isConnectedToWebSocket = false
            print(error!)
        }
    }
    
    func onConnect(_ headers: [String: String]) {
        print( headers )
    }
    
    func onDisConnect(_ reason: String, _ code: UInt16) {
        
    }
    
    func onReceivedText(_ text: String) {
        print(text)
    }
    
    func onReceivedData(_ data: Data?) {
        
    }
}


extension Collection {
    func randomElements(_ count: Int) -> [Element] {
        var shuffledIterator = shuffled().makeIterator()
        return (0..<count).compactMap { _ in shuffledIterator.next() }
    }
}

extension Base {
    class func generateRandomDate(daysBack: Int = 10)-> Date?{
        let day = arc4random_uniform(UInt32(daysBack))+1
        let hour = arc4random_uniform(23)
        let minute = arc4random_uniform(59)
        
        let today = Date(timeIntervalSinceNow: 0)
        let gregorian  = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        var offsetComponents = DateComponents()
        offsetComponents.day = -1 * Int(day - 1)
        offsetComponents.hour = -1 * Int(hour)
        offsetComponents.minute = -1 * Int(minute)
        
        let randomDate = gregorian?.date(byAdding: offsetComponents, to: today, options: .init(rawValue: 0) )
        return randomDate
    }
    
    class func fetchMockData() -> ([String],AssetsBalances){
        let assets = ["BTC","ETH","XRP","SOL","BCH","LTC","DOGE","USDT","USDC","BNB","ADA","DOT"].randomElements(Int.random(in: 4..<10))
        var balances: AssetsBalances = [:]
        for asset in assets {
            let lower: Float = asset == "BTC" ? 0.89 : 4
            let upper: Float = asset == "BTC" ? 2.01 : 20
            balances[asset] = (Float.random(in: lower..<upper),0.0)
        }
        return (assets, balances)
    }
    
    class func fetchMockPendingOrderData() -> [PendingOrder] {
        var pendingOrders:[PendingOrder] = []
        let pairs = ["ETHBTC","XRPBTC","BTCUSD","BTCUSDT","ETHADA","XRPZAR","ETHUSD","BTCGBP","DOGEUSDT","DOTBTC"].randomElements( Int.random(in: 4..<9)  )
        let data : [String:(Float,Float,Int)] = ["ETHBTC":(0.04,0.0567,Int.random(in: 10..<20)),
                                          "XRPBTC":(0.0000016,0.00000174,Int.random(in: 100000..<200000)),
                                          "BTCUSD":(20000,21500,Int.random(in: 2..<4)),
                                          "BTCUSDT":(20000,21500,Int.random(in: 1..<3)),
                                          "ETHADA":(0.0004,0.00045,Int.random(in: 10..<20)),
                                          "XRPZAR":(5.4,5.9,Int.random(in: 200..<400)),
                                          "ETHUSD":(1200,1220,Int.random(in: 10..<20)),
                                          "BTCGBP":(17200,17210,Int.random(in: 1..<4)),
                                          "DOGEUSDT":(0.06,0.065,Int.random(in: 10000..<20000)),
                                          "DOTBTC":(0.0003,0.00038,Int.random(in: 100..<200))
                                         ]
        for pair in pairs {
            if let price = data[pair], let date = Base.generateRandomDate(daysBack: Int.random(in: 10..<20)) {
                let d = Base.dateFormatter.string(from: date )
                pendingOrders.append(  ( "MOCK_ORDER_\(pair)",pair,"\(Float.random(in: price.0..<price.1))","\(Float(price.2))",d) )
            }
        }
        return pendingOrders
    }
}
