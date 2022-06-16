//
//  ApiKey.swift
//  hodl
//
//  Created by Emmanuel Adigun on 2022/06/11.
//

import Foundation

struct ApiKey: Codable {
    let exchange: String
    let key: String
    let secret: String
    let userid: String //some exchanges require this
    let password: String //some exchanges require this
    let description: String //optional description
    let dateadded: Date
    let active: Bool
    
    init(_ exchange: String, _ key: String = "" , _ secret: String = "" , _ userid: String = "", _ password: String = "",_ description: String = "", _ date: Date = Date(), _ active: Bool = true) {
        self.exchange = exchange
        self.key = key
        self.secret = secret
        self.userid = userid
        self.password = password
        self.description = description
        self.dateadded = date
        self.active = active
    }
    
    func isValid(_ base: Base ) -> Bool {
        var isValid = true
        let oldAuth = base.credentials
        base.setCredentials( .basic(self.key, self.secret) )
        let urlRequest = base.buildURL(base.urls.balances)
        let response : WebServiceCallbackValues = base.queueRequest(urlRequest)
        if let error = response.1 {
            print( error )
            base.setCredentials(oldAuth)
            isValid = false
        }
        return isValid
    }
}

