//
//  EndPoints.swift
//  Part of Hodl.
//
//  Created by Emmanuel Adigun on 2022/06/02. emmanuel@zignal.net
//  Copyright © 2022. All rights reserved.

import Foundation

typealias EndPoint = (String,EndPoints.Method,String)

enum EndPoints : String {
    case LUNO
    case VALR
    case BINANCE
    case COINBASE
    case CONVERSION_MULTI
    case CONVERSION_SINGLE
    case UNDEFINED
    
    enum Method: String {
        case GET
        case POST
        case PUT
        case DELETE
        case NONE
    }
    
    init(value: String) {
        self =  EndPoints(rawValue: value.uppercased()) ?? .UNDEFINED
    }
    
    var baseurl: String {
        switch self {
            case .LUNO:                 return "https://api.mybitx.com/api/1"
            case .VALR:                 return "https://api.valr.com"
            case .BINANCE:              return "https://api.binance.com"
            case .COINBASE:             return "https://api.exchange.coinbase.com"
            case .CONVERSION_MULTI:     return "https://min-api.cryptocompare.com/data/pricemulti"
            case .CONVERSION_SINGLE:    return "https://min-api.cryptocompare.com/data/price"
            case .UNDEFINED:            return ""
        }
    }
    
    var balances: EndPoint {
        switch self {
            case .LUNO:                 return ("\(self.baseurl)/balance",.GET,"/balance")
            case .VALR:                 return ("\(self.baseurl)/v1/account/balances",.GET,"/v1/account/balances")
            case .BINANCE:              return ("\(self.baseurl)/api/v3/account", .GET, "/api/v3/account")
            case .COINBASE:             return ("\(self.baseurl)/accounts", .GET, "/v2/accounts")
            case .CONVERSION_MULTI:     return ("",.GET,"")
            case .CONVERSION_SINGLE:    return ("",.GET,"")
            case .UNDEFINED:            return ("",.NONE,"")
        }
    }
    
    var orders: EndPoint {
        switch self {
            case .LUNO:                 return ("\(self.baseurl)/listorders",.GET,"/balance")
            case .VALR:                 return ("\(self.baseurl)/v1/orders/open",.GET,"/v1/orders/open")
            case .BINANCE:              return ("\(self.baseurl)/api/v3/openOrders", .GET, "/api/v3/openOrders")
            case .COINBASE:             return ("\(self.baseurl)/orders", .GET, "/v2/orders")
            case .CONVERSION_MULTI:     return ("",.GET,"")
            case .CONVERSION_SINGLE:    return ("",.GET,"")
            case .UNDEFINED:            return ("",.NONE,"")
        }
    }
    
    var streams: String {
        switch self {
            case .LUNO:                 return "wss://ws.luno.com/api/1/userstream"
            case .VALR:                 return ""
            case .BINANCE:              return ""
            case .COINBASE:             return ""
            case .CONVERSION_MULTI:     return ""
            case .CONVERSION_SINGLE:    return ""
            case .UNDEFINED:            return ""
        }
    }
}
