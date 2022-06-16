//
//  Exchanges.swift
//  Part of Hodl.
//
//  Created by Emmanuel Adigun on 2022/06/02. emmanuel@zignal.net
//  Copyright © 2022. All rights reserved.

import Foundation
import LiteDB

class Exchanges: Table {
    
    let id     = Column(name: "e_uid", primary_key: true, auto_increment: true)
    let name   = Column(name: "e_name")
    
    override var tablename: String { return "e_exchanges" }
    public static var singleInstance: Exchanges = { return Exchanges(db: HodlDb) }()
    
    func find(_ name: String ) -> Exchanges? {
        do {
            return try rows(" UPPER(e_name) = '\(name.uppercased())' ").first
        }
        catch( let error ) {
            print( error )
        }
        return nil
    }
}
