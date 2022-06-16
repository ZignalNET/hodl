//
//  Luno.swift
//  Part of Hodl.
//
//  Created by Emmanuel Adigun on 2022/06/02.
//  Copyright © 2022 Zignal Systems. All rights reserved.
//

import Foundation
import UIKit

class Luno: Base {
    
    public static let singleInstance = Luno("LUNO", .none)
    
    override func signRequest(_ urlRequest: inout URLRequest, _ extra: ((String,String),EndPoints.Method)? = nil) {
        urlRequest.setValue("Basic \(credentials.authString)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
            
            if let data = Base.convertAssets(assets.joined(separator: ","),base) {
                if let b = balances[base] { total += b.0 }
                for d in data {
                    let key = d.key
                    let value = d.value as! Dictionary<String,NSNumber>
                    if let rate = value[base] {
                        //print(key,rate)
                        if let balance = balances[key] {
                            let t = balance.0
                            balances[key]?.1 = t * rate.floatValue
                            total += balances[key]!.1
                        }
                    }
                }
            }
            
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
        if  let data = Base.synchronousQuery(address: "https://api.luno.com/api/1/ticker?pair=XBTZAR"),
            let a = data["last_trade"] {
            rate = Float(a as! String) ?? rate
        }
        return rate
    }
    
}
