//
//  Assets.swift
//  hodl
//
//  Created by Emmanuel Adigun on 2022/06/14.
//

import Foundation
import LiteDB

class Assets: Table {
    
    let id     = Column(name: "a_uid", primary_key: true, auto_increment: true)
    let name   = Column(name: "a_name")
    
    override var tablename: String { return "a_assets" }
    public static var singleInstance: Assets = { return Assets(db: HodlDb) }()
}


extension Assets {
    class func add(_ name: String ) {
        do {
            let asset = Assets.singleInstance
            if try asset.rows(" UPPER(a_name) = '\(name.uppercased())' ").count == 0 {
                asset["name"] = name
                let _ = try asset.insert()
            }
        }
        catch( let error ) {
            print( error )
        }
    }
    
    class func add(_ names: [String]? ) {
        if let names = names { for name in names { add(name) } }
    }
    
    func find(_ name: String ) -> Assets? {
        do {
            return try rows(" UPPER(a_name) = '\(name.uppercased())' ").first
        }
        catch( let error ) {
            print( error )
        }
        return nil
    }
}
