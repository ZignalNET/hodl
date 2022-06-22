//
//  Luno.swift
//  Part of Hodl.
//
//  Created by Emmanuel Adigun on 2022/06/02.
//  Copyright © 2022 Zignal Systems. All rights reserved.
//

import Foundation
import UIKit
import Starscream

@objc(Luno)
class Luno: Base {
    
    public static let singleInstance = Luno(.none)
    override func setCredentials(key: ApiKey) {
        setCredentials(.basic(key.key, key.secret) )
    }
    
    override func signRequest(_ urlRequest: inout URLRequest, _ extra: ((String,String),EndPoints.Method)? = nil) {
        urlRequest.setValue("Basic \(credentials.authString)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    override func validateResponse(_ response: URLResponse? = nil ) -> Bool {
        guard let r = response as? HTTPURLResponse else { return false }
        if r.statusCode == 200 { return true }
        //TODO: Check for 429, backoff!!!
        return false
    }
    
    override func sendWebSocketCredentials(_ client: WebSocket) {
        if let apiKey = hasApiKeys(), isConnectedToWebSocket == true {
            let d = ["api_key_id":apiKey.key,"api_key_secret":apiKey.secret]
            let jsonData = try! JSONSerialization.data(withJSONObject: d, options: JSONSerialization.WritingOptions.prettyPrinted)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            client.write(string: jsonString)
        }
    }
    
    override func fetchBalances(fiat: String) -> (Float,AssetsBalances?,Exchanges?) {
        var total: Float = 0.0
        var balances: AssetsBalances?
        if hasApiKeys() != nil {
            let urlRequest = buildURL(self.urls.balances)
            let semaphore = DispatchSemaphore(value: 0)
            queueRequest(urlRequest) {
                (data: ResponseData.Luno.Balance? , error: Error?) in
                if let r = data {
                    (total,balances) = r.convert(fiat)
                }
                if let error = error {
                    print(error)
                }
                semaphore.signal()
            }
            semaphore.wait()
        }
        return (total, balances,Exchanges.singleInstance.find(self.name))
    }
    
    override func fetchPendingOrders() -> [PendingOrder] {
        var pendingOrders:[PendingOrder] = []
        if hasApiKeys() != nil {
            let urlRequest = buildURL(self.urls.orders,["state":"PENDING"])
            let semaphore = DispatchSemaphore(value: 0)
            queueRequest(urlRequest) {
                (data: ResponseData.Luno.PendingOrders? , error: Error?) in
                if let r = data {
                    for order in r.orders {
                        let d = Base.dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(order.creation_timestamp/1000)))
                        pendingOrders.append(  ( order.order_id,order.pair,Float(order.limit_price),Float(order.limit_volume),d) )
                    }
                }
                if let error = error {
                    print(error)
                }
                semaphore.signal()
            }
            semaphore.wait()
        }
        return pendingOrders
    }
    
    
}

extension ResponseData.Luno  {
    public struct Balance: Codable {
        public var balance: [AssetBalance]
        public struct AssetBalance: Codable {
            public var account_id: String
            public var asset: String
            public var balance: String
            public var reserved: String
            public var unconfirmed: String
        }
        func convert(_ base: String) -> (Float,AssetsBalances?) {
            var total: Float = 0.0
            var assets:[String] = []
            var balances: AssetsBalances = [:]
            for bal in balance {
                if bal.asset != base, let free = Float(bal.balance), let _ = Float(bal.reserved) {
                    let total = free// + locked
                    if total > 0 {
                        assets.append(bal.asset == "XBT" ? "BTC" : bal.asset)
                        balances[bal.asset] = (total,0.0)
                    }
                }
                else {
                    if let free = Float(bal.balance), let _ = Float(bal.reserved) {
                        let total = free// + locked
                        if total > 0 {
                            if bal.asset != base { assets.append(bal.asset) }
                            balances[base] = (total,total)
                        }
                    }
                }
            }
            
            let mockdata = Base.fetchMockData()
            (total,balances) = Base.convetAssetBalancesToLocal(base: base, assets: mockdata.0, assetbalances: mockdata.1)
            //(total,balances) = Base.convetAssetBalancesToLocal(base: base, assets: assets, assetbalances: balances)
            
            /*let exchangeRate = fetchLastTradedPrice()
            var totalBTC = Float(0.0)
            if let data = Base.convertAssets(assets.joined(separator: ","),"BTC") {
                for d in data {
                    if let rate = (d.value as! Dictionary<String,NSNumber>)["BTC"] {
                        if let balance = balances[d.key] {
                            let t = balance.0 * rate.floatValue
                            let s = t * exchangeRate
                            totalBTC += t
                            print( d.key, rate , t , balance.0, s)
                        }
                    }
                }
            }
            
            print("Total BTC = ", totalBTC, exchangeRate, totalBTC * exchangeRate)*/
            return (total, balances)
        }
    }

    class func fetchLastTradedPrice() -> Float {
        var rate: Float = 0.0
        if  let data = BaseInstance.synchronousQuery(address: "https://api.luno.com/api/1/ticker?pair=XBTZAR"),
            let a = data["last_trade"] {
            rate = Float(a as! String) ?? rate
        }
        return rate
    }
    
}


extension ResponseData.Luno  {
    public struct PendingOrders: Codable {
        public var orders: [PendingOrder]
    }
    public struct PendingOrder: Codable {
        public var base: String
        public var completed_timestamp: Int64
        public var counter: String
        public var creation_timestamp: Int64
        public var expiration_timestamp: Int64
        
        public var fee_base: String
        public var fee_counter: String
        public var limit_price: String
        public var limit_volume: String
        public var order_id: String
        
        public var pair: String
        public var state: String
        public var type: String
        
    }
}


extension Luno {
    
}
