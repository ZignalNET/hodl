//
//  Balances.swift
//  hodl
//
//  Created by Emmanuel Adigun on 2022/06/15.
//
import Foundation
import LiteDB

class Balances: Table {
    
    let id          = Column(name: "b_uid", primary_key: true, auto_increment: true)
    let eid         = Column(name: "b_e_uid", type: .INTEGER) //exchange uid
    let aid         = Column(name: "b_a_uid", type: .INTEGER) //asset uid
    let currency    = Column(name: "b_currency", type: .TEXT)
    let total       = Column(name: "b_total", type: .TEXT)
    let value       = Column(name: "b_value", type: .TEXT)
    let period       = Column(name: "b_period", type: .INTEGER)
    let dateadded   = Column(name: "b_dateadded", type: .DATETIME, default_value: "(DATETIME(CURRENT_TIMESTAMP, 'LOCALTIME'))")
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHH"
        formatter.locale = Locale.current
        return formatter
    }()
    
    override var tablename: String { return "b_balances" }
    public static var singleInstance: Balances = { return Balances(db: HodlDb) }()
}

extension Balances {
    func add(_ eid: Int32, _ aid: Int32, _ currency: String, _ total: String, _ value : String, _ formatter: String = Balances.dateFormatter.dateFormat) {
        let balance = self
        balance["eid"] = eid
        balance["aid"] = aid
        balance["currency"] = currency
        balance["total"] = total
        balance["value"] = value
        Balances.dateFormatter.dateFormat = formatter
        let period = Balances.dateFormatter.string(from: Date())
        balance["period"] = period
        
        do {
            if let b = find(eid, aid, currency, period) {
                balance["id"] = b["id"]!
                let _ = try balance.update()
            }
            else { let _ = try balance.insert() }
        }
        catch( let error ) {
            print( error )
        }
    }
    
    func find(_ eid: Int32, _ aid: Int32, _ currency: String, _ period: String) -> Balances? {
        do {
            return try rows(" b_e_uid = \(eid) AND b_a_uid = \(aid) AND UPPER(b_currency) = '\(currency.uppercased())' AND b_period = '\(period)'").first
        }
        catch( let error ) {
            print( error )
        }
        return nil
    }
    
    class Bal: NSObject {
        @objc var period = 0
        @objc var total  = 0.0
    }
    
    func list() {
        do {
            let sql = "select b_period as period, sum(cast(b_value as decimal)) as total from b_balances group by b_period"
            if let rows: [Bal] = try self.getDB()?.query(sql, nil , nil ) {
                for row in rows {
                    print(row.period, row.total)
                }
            }
            
        }
        catch( let error ) {
            print( error )
        }
    }
}
