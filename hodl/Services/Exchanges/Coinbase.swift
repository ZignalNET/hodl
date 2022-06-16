//
//  Coinbase.swift
//  hodl
//
//  Created by Emmanuel Adigun on 2022/06/13.
//

import Foundation

class Coinbase: Base {
    static let API_VERSION = "2018-05-30"
    public static let singleInstance = Coinbase("Coinbase", .none)
    
    override func signRequest( _ urlRequest: inout URLRequest, _ extra: ((String,String),EndPoints.Method)? = nil) -> Void {
        var params: String = ""
        let agent = self.UserAgentString()
        
        let encoding = "gzip, deflate"
        let ts = Int64(Date().timeIntervalSince1970)
        if let method = urlRequest.httpMethod, let uri = urlRequest.url {
            params =  "\(ts)" + "\(method)" + "\(uri.path)"
        }
        let signature = credentials.secret.HMAC(params)
        urlRequest.addValue(Coinbase.API_VERSION,       forHTTPHeaderField: "CB-VERSION")
        urlRequest.addValue(credentials.key,            forHTTPHeaderField: "CB-ACCESS-KEY")
        urlRequest.addValue(signature,                  forHTTPHeaderField: "CB-ACCESS-SIGN")
        urlRequest.addValue("\(ts)",                    forHTTPHeaderField: "CB-ACCESS-TIMESTAMP")
        urlRequest.addValue("application/json",         forHTTPHeaderField: "Content-Type")
        urlRequest.addValue(agent,                      forHTTPHeaderField: "User-Agent")
        urlRequest.addValue(encoding,                   forHTTPHeaderField: "Accept-Encoding")
    }
    
    override func fetchBalances(fiat: String) -> (Float,AssetsBalances?,Exchanges?) {
        var total: Float = 0.0
        var balances: AssetsBalances?
        if hasApiKeys() != nil {
            let urlRequest = buildURL(self.urls.balances)
            let semaphore = DispatchSemaphore(value: 0)
            queueRequest(urlRequest) {
                (data: ResponseData.Coinbase.Balance? , error: Error?) in
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


extension ResponseData.Coinbase {
    public struct Balance: Codable {
        public var pagination: ResponseData.Coinbase.Pagination
        public var data: [ResponseData.Coinbase.Data]
        
        func convert(_ base: String) -> (Float,AssetsBalances?) {
            var total: Float = 0.0
            var assets:[String] = []
            var balances: AssetsBalances = [:]
            
            for bal in data {
                if bal.currency.code != base {
                    if let total = Float(bal.balance.amount), total > 0 {
                        assets.append(bal.currency.code)
                        balances[bal.currency.code] = (total,0.0)
                    }
                }
                else {
                    if let total = Float(bal.balance.amount), total > 0 {
                        balances[base] = (total,total)
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
            
            return (total, balances)
        }
        
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
