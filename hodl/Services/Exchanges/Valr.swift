//
//  Valr.swift
//  Part of Hodl.
//
//  Created by Emmanuel Adigun on 2022/06/02. emmanuel@zignal.net
//  Copyright © 2022. All rights reserved.

import Foundation

class Valr: Base {
    
    public static let singleInstance = Valr("VALR", .none)
    
    override func signRequest(_ urlRequest: inout URLRequest, _ extra: ((String,String),EndPoints.Method)? = nil) {
        if let path = extra {
            let timestamp = Base.timestamp
            let params = "\(timestamp)\(path.1)\(path.0.1)"
            let signature = credentials.secret.HMAC(params, algorithm: .sha512)
            urlRequest.addValue(credentials.key, forHTTPHeaderField: "X-VALR-API-KEY")
            urlRequest.addValue(signature,       forHTTPHeaderField: "X-VALR-SIGNATURE")
            urlRequest.addValue("\(timestamp)",  forHTTPHeaderField: "X-VALR-TIMESTAMP")
        }
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
                (data: [ResponseData.Valr.Balance]? , error: Error?) in
                if let r = data {
                    let p = r.filter({
                        if let total = Float($0.total), total > 0 { return true }
                        return false
                    })
                    (total,balances) = self.convert(fiat, p )
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
    
    func convert(_ base: String = "ZAR", _ balances: [ResponseData.Valr.Balance]) -> (Float,AssetsBalances?) {
        var total: Float = 0.0
        var assets:[String] = []
        var assetbalances: AssetsBalances = [:]
        for balance in balances {
            if let free = Float(balance.total),free > 0 {
                if balance.currency != base {
                    assets.append(balance.currency)
                    assetbalances[balance.currency] = (free,0)
                }
                else {
                    assetbalances[base] = (free,free)
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

extension ResponseData.Valr {
    public struct Balance: Codable {
        public var currency: String
        public var available: String
        public var reserved: String
        public var total: String
        public var updatedAt: String?
    }
}
