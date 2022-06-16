//
//  helper.swift
//  Part of my local repo
//
//  Created by Emmanuel Adigun on 2021/06/24.
//  Copyright © 2021 Zignal Systems. All rights reserved.
//

import UIKit

let NO  = false
let YES = true
let OFF = NO
let ON  = YES

enum GenericTableSwipeMenuAction: Int {
    case AddRow = 0
    case EditRow = 1
    case DeleteRow = 2
    case ConfigureCell = 3
    case SelectCell = 4
    case Block = 5
    case UnBlock = 6
    
    case CancelOrder = 7
    case CancelTrade = 8
    case LiquidateOrder = 9
    
    var Action: String {
        switch self {
        case .AddRow:
            return "Add"
        case .EditRow:
            return "Edit"
        case .DeleteRow:
            return "Delete"
        case .ConfigureCell:
            return "ConfigureCell"
        case .SelectCell:
            return "Select"
        case .Block:
            return "Block"
        case .UnBlock:
            return "UnBlock"
        case .CancelOrder:
            return "Cancel"
        case .CancelTrade:
            return "Cancel"
        case .LiquidateOrder:
            return "Liquidate"
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .AddRow:
            return UIColor.mediumSeaGreenColor
        case .EditRow:
            return UIColor.mediumSeaGreenColor
        case .DeleteRow:
            return UIColor.defaultAppStrongColor
        case .ConfigureCell:
            return .clear
        case .SelectCell:
            return .clear
        case .Block:
            return UIColor.defaultAppStrongColor
        case .UnBlock:
            return UIColor.mediumSeaGreenColor
        case .CancelOrder:
            return UIColor.mediumSeaGreenColor
        case .CancelTrade:
            return UIColor.mediumSeaGreenColor
        case .LiquidateOrder:
            return UIColor.defaultAppStrongColor
        }
    }
    
    func isValid() -> Bool {
        //return [.AddRow, .EditRow, .DeleteRow,.Block,.UnBlock,.CancelOrder].contains(self)
        return true
    }
    
}

