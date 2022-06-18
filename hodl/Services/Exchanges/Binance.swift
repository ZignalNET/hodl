//
//  Binance.swift
//  Part of Hodl.
//
//  Created by Emmanuel Adigun on 2022/06/02. emmanuel@zignal.net
//  Copyright © 2022. All rights reserved.

import Foundation

class Binance: Base {
    public static let singleInstance = Binance("BINANCE", .none)
    
    override func signRequest(_ urlRequest: inout URLRequest, _ extra: ((String,String),EndPoints.Method)? = nil) {
        urlRequest.url?.appendQueryItem("timestamp", String(Base.timestamp) )
        var params: String = ""
        if let url = urlRequest.url, let query = url.query {
            params = query //qry params
        }
        let signature = credentials.secret.HMAC(params)
        urlRequest.url?.appendQueryItem("signature", signature )
        urlRequest.addValue(credentials.key, forHTTPHeaderField: "X-MBX-APIKEY")
    }
    
    override func validateResponse(_ response: URLResponse? = nil ) -> Bool {
        guard let r = response as? HTTPURLResponse else { return false }
        if r.statusCode == 200 { return true }
        //TODO: Check for 429, backoff!!!
        return false
    }
    
    override func fetchBalances(fiat: String) -> (Float,AssetsBalances?,Exchanges?) {
        var total: Float = 0.0
        var balances: AssetsBalances?
        if hasApiKeys() != nil {
            let urlRequest = buildURL(self.urls.balances)
            let semaphore = DispatchSemaphore(value: 0)
            queueRequest(urlRequest) {
                (data: ResponseData.Binance.Balance? , error: Error?) in
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
    
}


extension ResponseData.Binance {
    public struct Balance: Codable {
        public var makerCommission: Int
        public var takerCommission: Int
        public var buyerCommission: Int
        public var sellerCommission: Int
        public var canTrade: Bool
        public var canWithdraw: Bool
        public var canDeposit: Bool
        public var updateTime: Int
        public var balances: [AssetBalance]
        
        public func convert(_ base: String) -> (Float,AssetsBalances?) {
            var total: Float = 0.0
            var assets:[String] = []
            var assetbalances: AssetsBalances = [:]
            for balance in balances {
                if let free = Float(balance.free), let locked = Float(balance.locked), locked > 0 || free > 0 {
                    let total = free + locked
                    if total > 0 {
                        if balance.asset != base {
                            assets.append(balance.asset)
                            assetbalances[balance.asset] = (total,0)
                        }
                        else {
                            assetbalances[base] = (total,total)
                        }
                    }
                }
            }
            
            if let data = Base.convertAssets(assets.joined(separator: ","),base) {
                if let b = assetbalances[base] { total += b.0 }
                for d in data {
                    let key = d.key
                    let value = d.value as! Dictionary<String,NSNumber>
                    if let rate = value[base] {
                        //print(key,rate)
                        if let balance = assetbalances[key] {
                            let t = balance.0
                            assetbalances[key]?.1 = t * rate.floatValue
                            total += assetbalances[key]!.1
                        }
                    }
                }
            }
            
            return (total,assetbalances)
        }
    }

    public struct AssetBalance: Codable {
        public var asset: String
        public var free: String
        public var locked: String
        
        lazy var btcValue: Float = 0.0
        lazy var fiatValue: Float = 0.0
        
        mutating func fetchConvertedValue(_ toValue: String = "BTC") -> Float {
            var val: Float = 0
            if let r = Base.convertAssets(asset, toValue), let btc = r[toValue] as? NSNumber {
                let a: Float = btc.floatValue
                let b: Float = Float(free)! + Float(locked)!
                val = (a * b)
            }
            return val
        }
    }
}
