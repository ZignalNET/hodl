//
//  Date.swift
//  Part of my local repo
//
//  Created by Emmanuel Adigun on 2020/04/25.
//  Copyright © 2020. All rights reserved.
//

import Foundation

extension Date {
    func daysInMonth() -> Int{
        let calendar        = Calendar.current
        let dateComponents  = DateComponents(year: calendar.component(.year, from: self), month: calendar.component(.month, from: self))
        guard let date      = calendar.date(from: dateComponents), let dc = calendar.range(of: .day, in: .month, for: date) else { return 0 }
        return dc.count
    }
}
