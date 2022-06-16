//
//  Notification.swift
//  hodl
//
//  Created by Emmanuel Adigun on 2022/06/09.
//  Copyright © 2022. All rights reserved.

import Foundation

extension Notification.Name {
    static let refreshExchangeDataTotals = Notification.Name("refreshExchangeDataTotals")
    static let refreshExchangeDataSummaries = Notification.Name("refreshExchangeDataSummaries")
    static let refreshExchangeDataDetails = Notification.Name("refreshExchangeDataDetails")
    
    static let refreshGenericTableViewData       = Notification.Name("refreshGenericTableViewData")
}

