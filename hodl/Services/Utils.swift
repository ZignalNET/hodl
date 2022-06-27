//
//  Utils.swift
//  Part of Hodl.
//
//  Created by Emmanuel Adigun on 2022/06/02. emmanuel@zignal.net
//  Copyright © 2022. All rights reserved.
import SystemConfiguration
import Foundation
import LiteDB

let exchanges = Exchanges.singleInstance
let ExchangeObjects: [String: Base] = ["LUNO":Luno.singleInstance,"VALR":Valr.singleInstance,"BINANCE":Binance.singleInstance,"COINBASE":Coinbase.singleInstance]

var globalLocalCurrency: String {
    get { return UserDefaults.standard.string(forKey: "LOCALCURRENCY") ?? "EUR" }
    set {  UserDefaults.standard.set(newValue, forKey: "LOCALCURRENCY")  }
}

func fetchDefaultExchangeData() -> [(String,(Float,AssetsBalances?,Exchanges?))] {
    var data: [ (String,(Float,AssetsBalances?,Exchanges?)) ] = []
    let balance: AssetsBalances? = nil
    for exchange in fetchExchanges() {
        if let name = exchange["name"] as? String {
            let a = (Float(0),balance,Exchanges.singleInstance.find(name))
            let b: (String,(Float,AssetsBalances?,Exchanges?)) = (name,a)
            data.append(b)
        }
    }
    return data
}

func initExchanges() {
    let objects = ["LUNO","VALR","Binance","Coinbase"]
    do {
        for o in objects {
            if try exchanges.rows(" UPPER(e_name) = '\(o.uppercased())' ").count == 0 {
                exchanges["name"] = o
                _ = try exchanges.insert()
            }
        }
    }
    catch( let error ) {
        print( error )
    }
}

func fetchExchanges() -> [Exchanges] {
    if exchanges.count == 0 { return [] }
    do {
        return try exchanges.rows()
    }
    catch( let error ) {
        print( error )
    }
    return []
}

func initModels() {
    initExchanges()
}

func fetchConnectedExchanges() -> [String] {
    var exchanges: [String] = []
    for exchange in fetchExchanges() {
        if exchange.hasApiKey() { exchanges.append(exchange["name"] as! String) }
    }
    return exchanges
}

func fetchAllExchanges(_ localFiat: String) {
    guard isConnectedToInternet() else { return }
    DispatchQueue.global(qos: .background).async {
        var balances:[(Float,AssetsBalances?,Exchanges?)] = []
        var pendingOrders: [String:(Int,PendingOrders)] = [:]
        for exchange in fetchExchanges() {
            if let name = exchange["name"] as? String, let e = NSClassFromString(name.capitalized) as? Base.Type {
                let l = e.init(.none)
                let b = l.fetchBalances(fiat: localFiat)
                let p = l.fetchPendingOrders()
                balances.append(b)
                pendingOrders[name] = (p.count,p)
            }
        }
        
        let total   = balances.map({$0.0}).reduce(0,+)  //Sum of totals
        let btc     = Base.convertAssets(localFiat, "BTC", false)
        let local   = Base.convertAssets("BTC", "\(localFiat),USD", false)
        
        let names = balances.map({ $0.1?.map({ $0.key }) }).filter({ $0 != nil })
        for name in names { Assets.add(name) }
        let exchanges = balances.filter({ $0.1 != nil && $0.2 != nil }).map({ ($0.2! , $0.1 ?? [:]) })
        for exchange in exchanges {
            if let eid = exchange.0["id"] as? Int32 {
                for asset in exchange.1 {
                    if let a = Assets.singleInstance.find(asset.key), let aid = a["id"] as? Int32 {
                        Balances.singleInstance.add(eid, aid, localFiat, String(format:"%.10f",asset.value.0), String(format:"%.10f",asset.value.1))
                    }
                }
            }
        }
    
        DispatchQueue.main.async {
            //On main thread
            if let btc = btc?.first, let local = local, let btcUSD = local["USD"] as? NSNumber, let btcLocal = local[localFiat] as? NSNumber{
                var userObject: [String:Float] = [:]
                var userInfo:   [String:Float] = [:]
                var details:    [String:(Float,AssetsBalances?,Exchanges?)]  = [:]
                userInfo["localtotal"]  = total
                userInfo["btctotal"]    = total * (btc.value as! NSNumber).floatValue
                userInfo["btcUSD"]      = btcUSD.floatValue
                userInfo["btcLocal"]    = btcLocal.floatValue
                
                for balance in balances {
                    if let e = balance.2, let name = e["name"] as? String{
                        userObject[name.capitalized]        = balance.0
                        details[name.uppercased()]          = balance
                    }
                }
                
                NotificationCenter.default.post(name: .refreshExchangeDataTotals, object: userObject, userInfo: userInfo)
                NotificationCenter.default.post(name: .refreshExchangeDataDetails, object: details, userInfo: pendingOrders)
            }
        }
    }
}

func isConnectedToInternet() -> Bool {
    var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
    zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    zeroAddress.sin_family = sa_family_t(AF_INET)

    guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else { return false }

    var flags: SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) { return false }
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    return (isReachable && !needsConnection) ? true : false
}

