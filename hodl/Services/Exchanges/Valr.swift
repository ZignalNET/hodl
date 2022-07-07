//
//  Valr.swift
//  Part of Hodl.
//
//  Created by Emmanuel Adigun on 2022/06/02. emmanuel@zignal.net
//  Copyright © 2022. All rights reserved.

import Foundation

@objc(Valr)
class Valr: Base {
    
    public static let singleInstance = Valr(.none)
    
    override func setCredentials(key: ApiKey) {
        setCredentials(.basic(key.key, key.secret) )
    }
    
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
        //let mockdata = Base.fetchMockData()
        //(total,balances) = Base.convetAssetBalancesToLocal(base: fiat, assets: mockdata.0, assetbalances: mockdata.1)
        if apiKey != nil {
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
        (total,assetbalances) = Base.convetAssetBalancesToLocal(base: base, assets: assets, assetbalances: assetbalances)
        return (total,assetbalances)
    }
    
    override func fetchPendingOrders() -> [PendingOrder] {
        var pendingOrders:[PendingOrder] = []
        if apiKey != nil {
            let urlRequest = buildURL(self.urls.orders)
            let semaphore = DispatchSemaphore(value: 0)
            queueRequest(urlRequest) {
                (data: [ResponseData.Valr.PendingOrder]? , error: Error?) in
                if let orders = data {
                    //print(orders)
                    for order in orders {
                        let d = order.createdAt//Base.dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(order.time/1000)))
                        pendingOrders.append(( "\(order.orderId)",order.currencyPair,order.price,order.originalQuantity,d))
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
        //return Base.fetchMockPendingOrderData()
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

extension ResponseData.Valr {
    public struct PendingOrder: Codable {
        public var orderId: String
        public var side: String
        public var remainingQuantity: String
        public var price: String
        public var currencyPair: String
        
        public var createdAt: String
        public var originalQuantity: String
        public var filledPercentage: String
        public var stopPrice: String
        public var updatedAt: String
        
        public var status: String
        public var type: String
        public var timeInForce: String
    }
}
