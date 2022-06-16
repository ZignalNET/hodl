//
//  KeyChainService.swift
//  Part of my local repo
//
//  Created by Emmanuel Adigun on 2020/04/25.
//  Copyright © 2020. All rights reserved.
//

import Foundation

typealias KeyChainValue = [String : Any]

class KeyChainService {
    
    private static let keychainService = Bundle.main.bundleIdentifier! + ".keychain.services"
    
    static func deleteKey(_ key: String ) -> Bool {
        let query = [kSecClass as String : kSecClassGenericPassword as String,
                     kSecAttrService as String : keychainService,
                     kSecAttrAccount as String : key
                    ]
            as KeyChainValue
        let deleteStatus = SecItemDelete(query as CFDictionary)
        if deleteStatus == noErr || deleteStatus == errSecItemNotFound { return true }
        return false 
    }
    
    static func saveKey(_ key: String, _ data: Data) -> Bool {
        let query = [kSecClass as String : kSecClassGenericPassword as String,
                     kSecAttrService as String : keychainService,
                     kSecAttrAccount as String : key,
                     kSecValueData as String   : data]
            as KeyChainValue

        if KeyChainService.deleteKey(key) {
            return SecItemAdd(query as CFDictionary, nil) == noErr
        }
        return false
    }
    
    static func saveKey<T: Codable>(_ key: String, _ data: T) -> Bool {
        do {
            let obj = try JSONEncoder().encode(data)
            if KeyChainService.saveKey(key, obj) { return true }
        } catch let err {
            print(#function, err)
        }
        return false
    }

    static func retrieveKey(_ key: String) -> Data? {
        let query = [kSecClass as String : kSecClassGenericPassword,
                     kSecAttrService as String : keychainService,
                     kSecAttrAccount as String : key,
                     kSecReturnAttributes as String : kCFBooleanTrue!,
                     kSecReturnData as String: kCFBooleanTrue!]
            as KeyChainValue

        var result: AnyObject? = nil
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == noErr,
            let dict = result as? KeyChainValue,
            let data = dict[String(kSecValueData)] as? Data {
            return data
        } else {
            return nil
        }
    }
    
    static func retrieveKey<T>(_ key: String) -> T? {
        guard let data = KeyChainService.retrieveKey(key) else { return nil }
        return data.to(T.self)
    }
    
    static func retrieveKey<T: Codable>(_ key: String) -> T? {
        guard let data = KeyChainService.retrieveKey(key) else { return nil }
        //return data.to(T.self)
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch let err {
            print(#function, err)
        }
        return nil
    }
    
    static func iterateKeychainItems(_ log: Bool = true, _ delete: Bool = false ) {
        let secItemClasses = [
            kSecClassGenericPassword/*,
            kSecClassInternetPassword,
            kSecClassCertificate,
            kSecClassKey,
            kSecClassIdentity*/
        ]

        if (log) {
            for secItemClass in secItemClasses {
                let query: KeyChainValue = [
                    kSecReturnAttributes as String: kCFBooleanTrue!,
                    kSecMatchLimit as String: kSecMatchLimitAll,
                    kSecClass as String: secItemClass
                ]

                var result: AnyObject?
                let status = SecItemCopyMatching(query as CFDictionary, &result)
                if status == noErr {
                    print(result as Any)
                }
            }
        }

        if (delete) {
            for secItemClass in secItemClasses {
                let dictionary = [kSecClass as String:secItemClass]
                SecItemDelete(dictionary as CFDictionary)
            }
        }
    }
}
