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
    get { return UserDefaults.standard.string(forKey: "LOCALCURRENCY") ?? "ZAR" }
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


func fetchExchangeData(_ localFiat: String ) {
    guard isConnectedToInternet() else { return }
    //TODO: Full rewrite of this function is a MUST; what if I have 1000 exchanges ????
    DispatchQueue.global(qos: .background).async {
        let luno    = Luno.singleInstance.fetchBalances(fiat: localFiat)
        let binance = Binance.singleInstance.fetchBalances(fiat: localFiat)
        let valr    = Valr.singleInstance.fetchBalances(fiat: localFiat)
        let coinbase = Coinbase.singleInstance.fetchBalances(fiat: localFiat)
        let total   = [luno.0,binance.0,valr.0, coinbase.0].reduce(0, +)
        let btc     = Base.convertAssets(localFiat, "BTC", false)
        let local   = Base.convertAssets("BTC", "\(localFiat),USD", false)
        
        let names = [luno,binance,valr,coinbase].map({ $0.1?.map({ $0.key }) }).filter({ $0 != nil })
        for name in names { Assets.add(name) }
        
        let exchanges = [luno,binance,valr,coinbase].filter({ $0.1 != nil && $0.2 != nil }).map({ ($0.2! , $0.1 ?? [:]) })
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
                
                userObject["Luno"]        = luno.0
                userObject["Binance"]     = binance.0
                userObject["Valr"]        = valr.0
                userObject["Coinbase"]    = coinbase.0
                
                details["LUNO"]           = luno
                details["BINANCE"]        = binance
                details["VALR"]           = valr
                details["Coinbase"]       = coinbase
                
                NotificationCenter.default.post(name: .refreshExchangeDataTotals, object: userObject, userInfo: userInfo)
                NotificationCenter.default.post(name: .refreshExchangeDataDetails, object: details, userInfo: nil)
            }
        }
    }
}


func onTimerExchangeCallback(_ timer: Timer ) {
    fetchExchangeData(globalLocalCurrency)
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

