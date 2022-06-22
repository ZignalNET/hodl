//
//  Binance.swift
//  Part of Hodl.
//
//  Created by Emmanuel Adigun on 2022/06/02. emmanuel@zignal.net
//  Copyright © 2022. All rights reserved.

import Foundation

@objc(Binance)
class Binance: Base {
    public static let singleInstance = Binance(.none)
    
    override func setCredentials(key: ApiKey) {
        setCredentials(.basic(key.key, key.secret) )
    }
    
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
    
    override func fetchPendingOrders() -> [PendingOrder] {
        var pendingOrders:[PendingOrder] = []
        if hasApiKeys() != nil {
            let urlRequest = buildURL(self.urls.orders)
            let semaphore = DispatchSemaphore(value: 0)
            queueRequest(urlRequest) {
                (data: [ResponseData.Binance.PendingOrder]? , error: Error?) in
                if let orders = data {
                    //print(orders)
                    for order in orders {
                        let d = Base.dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(order.time/1000)))
                        pendingOrders.append(  ( "\(order.orderId)",order.symbol,Float(order.price),Float(order.origQty),d) )
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
            let mockdata = Base.fetchMockData()
            (total,assetbalances) = Base.convetAssetBalancesToLocal(base: base, assets: mockdata.0, assetbalances: mockdata.1)
            //(total,assetbalances) = Base.convetAssetBalancesToLocal(base: base, assets: assets, assetbalances: assetbalances)
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

extension ResponseData.Binance {
    public struct PendingOrder: Codable {
        public var symbol: String
        public var orderId: Int64
        public var orderListId: Int64
        public var price: String
        public var origQty: String
        
        public var executedQty: String
        public var cummulativeQuoteQty: String
        public var status: String
        public var timeInForce: String
        public var type: String
        
        public var side: String
        public var stopPrice: String
        public var icebergQty: String
        
        public var time: Int64
        public var updateTime: Int64
        public var isWorking: Bool
        public var origQuoteOrderQty: String
    }
}


