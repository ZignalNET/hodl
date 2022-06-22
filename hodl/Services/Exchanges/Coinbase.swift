//
//  Coinbase.swift
//  hodl
//
//  Created by Emmanuel Adigun on 2022/06/13.
//

import Foundation
import CryptoKit

@objc(Coinbase)
class Coinbase: Base {
    public static let singleInstance = Coinbase(.none)
    
    override func setCredentials(key: ApiKey) {
        setCredentials(.extended(key.key, key.secret, key.password) )
    }
    
    override func signRequest( _ urlRequest: inout URLRequest, _ extra: ((String,String),EndPoints.Method)? = nil) -> Void {
        var params: String = ""
        let agent = "requests"
        
        let encoding = "gzip, deflate"
        let ts = Int64(Date().timeIntervalSince1970)
        if let method = urlRequest.httpMethod, let uri = urlRequest.url {
            params =  "\(ts)" + "\(method)" + "\(uri.path)"
            if let query = uri.query {
                params += "?\(query)"
            }
        }
        if let key: Data = Data(base64Encoded: credentials.secret), let data: Data = (params).data(using: .utf8) {
            let authcode = HMAC<SHA256>.authenticationCode(for: data, using: SymmetricKey(data: key))
            let signature = Data(authcode).base64EncodedString()
            urlRequest.addValue(credentials.key,            forHTTPHeaderField: "CB-ACCESS-KEY")
            urlRequest.addValue(credentials.password,       forHTTPHeaderField: "CB-ACCESS-PASSPHRASE")
            urlRequest.addValue(signature,                  forHTTPHeaderField: "CB-ACCESS-SIGN")
            urlRequest.addValue("\(ts)",                    forHTTPHeaderField: "CB-ACCESS-TIMESTAMP")
            urlRequest.addValue("application/json",         forHTTPHeaderField: "Content-Type")
            urlRequest.addValue(agent,                      forHTTPHeaderField: "User-Agent")
            urlRequest.addValue(encoding,                   forHTTPHeaderField: "Accept-Encoding")
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
                (data: [ResponseData.Coinbase.Balance]? , error: Error?) in
                if let r = data {
                    (total,balances) = self.convert(fiat, r)
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
            let urlRequest = buildURL(self.urls.orders, ["state":"pending"])
            let semaphore = DispatchSemaphore(value: 0)
            queueRequest(urlRequest) {
                (data: [ResponseData.Coinbase.Order]? , error: Error?) in
                if let orders = data {
                    //print(orders)
                    for order in orders {
                        let d = order.created_at
                        pendingOrders.append(( "\(order.id)",order.product_id,Float(order.price),Float(order.size),d))
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
    
    func convert(_ base: String, _ data: [ResponseData.Coinbase.Balance]) -> (Float,AssetsBalances?) {
        var total: Float = 0.0
        var assets:[String] = []
        var balances: AssetsBalances = [:]
        
        for bal in data {
            if bal.currency != base {
                if let total = Float(bal.balance), total > 0 {
                    assets.append(bal.currency)
                    balances[bal.currency] = (total,0.0)
                }
            }
            else {
                if let total = Float(bal.balance), total > 0 {
                    balances[base] = (total,total)
                }
            }
        }
        let mockdata = Base.fetchMockData()
        (total,balances) = Base.convetAssetBalancesToLocal(base: base, assets: mockdata.0, assetbalances: mockdata.1)
        //(total,balances) = Base.convetAssetBalancesToLocal(base: base, assets: assets, assetbalances: balances)
        return (total, balances)
    }
    
}


extension ResponseData.Coinbase {
    public struct Balance: Codable {
        public var id: String
        public var currency: String
        public var balance: String
        public var available: String
        public var hold: String
        
        public var profile_id: String
        public var trading_enabled: Bool
    }
}


extension ResponseData.Coinbase {
    
    public struct Pagination: Codable {
        public var ending_before: String?
        public var starting_after: String?
        public var limit: Int
        public var order: String
        public var previous_uri: String?
        public var next_uri: String?
    }
    
    public struct Data: Codable {
        public var id: String
        public var name: String?
        public var primary: Bool?
        public var type: String?
        public var currency: DataCurrency
        public var balance: DataBalance
        public var created_at: String?
        public var updated_at: String?
        public var resource: String?
        public var resource_path: String?
        public var ready: Bool?
    }
    
    public struct DataCurrency: Codable {
        public var code: String
        public var name: String
        public var color: String
        public var sort_index: Int
        public var exponent: Int
        public var type: String
        public var address_regex: String
        public var asset_id: String
        public var slug: String
    }
    
    public struct DataBalance: Codable {
        public var amount: String
        public var currency: String
        
        lazy var btcValue: Float = 0.0
        lazy var fiatValue: Float = 0.0
    }
}

extension ResponseData.Coinbase {
    public struct Order: Codable {
        public var id: String
        public var price: String
        public var size: String
        public var product_id: String
        public var profile_id: String
        
        public var side: String
        public var type: String
        public var time_in_force: String
        public var post_only: Bool
        public var created_at: String
        
        public var fill_fees: String
        public var filled_size: String
        public var executed_value: String
        
        public var status: String
        public var settled: Bool
    }
}

