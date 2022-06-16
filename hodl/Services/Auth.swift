//
//  Auth.swift
//  Part of Hodl.
//
//  Created by Emmanuel Adigun on 2022/06/02.
//  Copyright © 2022 Zignal Systems. All rights reserved.
//

import Foundation
import CommonCrypto

enum Auth: Equatable {
    case basic(_ key: String, _ secret: String)
    case extended(_ key: String, _ secret: String, _ password: String )
    case none
    
    var authString: String {
        switch self {
        case .basic(let key, let secret):
            let loginString = String(format: "%@:%@", key, secret)
            let loginData = loginString.data(using: String.Encoding.utf8)!
            return loginData.base64EncodedString()
        case .extended(let key, let secret, let password):
            let loginString = String(format: "%@:%@:%@", key, secret,password)
            let loginData = loginString.data(using: String.Encoding.utf8)!
            return loginData.base64EncodedString()
        case .none:
            return ""
        }
    }
    
    var key: String {
        switch self {
            case .basic(let key, _): return key
            case .extended(let key, _, _): return key
            case .none: return ""
        }
    }
    
    var secret: String {
        switch self {
            case .basic(_, let secret): return secret
            case .extended(_, let secret, _): return secret
            case .none: return ""
        }
    }
    
    var password: String {
        switch self {
            case .basic(_, _): return ""
            case .extended(_, _, let password): return password
            case .none: return ""
        }
    }
    
    func hmac(_ params: String ) -> String {
        return key.HMAC(params)
    }
    
    func isEmpty() -> Bool {
        return ((key.count == 0) || (secret.count == 0))
    }
    
}
