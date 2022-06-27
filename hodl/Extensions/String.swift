//
//  String+Extensions.swift
//  Part of my local repo
//
//  Created by Emmanuel Adigun on 2020/04/29.
//  Copyright © 2020. All rights reserved.
//

import Foundation
import CommonCrypto


enum HmacAlgorithm {
    case sha1, md5, sha256, sha384, sha512, sha224
    var algorithm: CCHmacAlgorithm {
        var alg = 0
        switch self {
            case .sha1:
                alg = kCCHmacAlgSHA1
            case .md5:
                alg = kCCHmacAlgMD5
            case .sha256:
                alg = kCCHmacAlgSHA256
            case .sha384:
                alg = kCCHmacAlgSHA384
            case .sha512:
                alg = kCCHmacAlgSHA512
            case .sha224:
                alg = kCCHmacAlgSHA224
        }
        return CCHmacAlgorithm(alg)
    }
    
    var digestLength: Int {
        var len: Int32 = 0
        switch self {
            case .sha1:
                len = CC_SHA1_DIGEST_LENGTH
            case .md5:
                len = CC_MD5_DIGEST_LENGTH
            case .sha256:
                len = CC_SHA256_DIGEST_LENGTH
            case .sha384:
                len = CC_SHA384_DIGEST_LENGTH
            case .sha512:
                len = CC_SHA512_DIGEST_LENGTH
            case .sha224:
                len = CC_SHA224_DIGEST_LENGTH
        }
        return Int(len)
    }
}


extension String {
    
    func HMAC(_ params: String, algorithm: HmacAlgorithm = .sha256 ) -> String {
        let key = self
        //print("Count = ", key.count, params.count )
        var digest = [UInt8](repeating: 0, count: algorithm.digestLength)
        CCHmac(algorithm.algorithm, key, key.count, params, params.count, &digest)
        let data = Data(digest)
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
    
    func toUtf8() -> String {
        if let d = self.data(using: .utf8) {
            return String(data: d, encoding: .utf8) ?? ""
        }
        return self
    }
    
    mutating func fromUtf8(_ utf8String: String ) {
        if let d = self.data(using: .utf8) {
            self = String(data: d, encoding: .nonLossyASCII) ?? ""
        }
    }
    
    private static var commaFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    internal var toCurrency: String {
        if let a = Float(self) {
            return String.commaFormatter.string(from: NSNumber(value: a)) ?? ""
        }
        return self
    }
    
    func toCurrency(_ decimalPlaces: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimalPlaces
        formatter.maximumFractionDigits = decimalPlaces
        if let a = Float(self) {
            return formatter.string(from: NSNumber(value: a)) ?? ""
        }
        return self
    }
    
}
