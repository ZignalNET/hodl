//
//  Reusable.swift
//  Part of my local repo
//
//  Created by Emmanuel Adigun on 2021/06/23.
//  Copyright © 2021. All rights reserved.
//

import UIKit

protocol Reusable {
    func onConfigureCell(cell: UITableViewCell, model: Any) -> Void
    func onSelectedCell(index: Int, cell: UITableViewCell, model: Any) -> Void
}

/// MARK: - UITableView
extension Reusable where Self: UITableViewCell  {
    static var reuseIdentifier: String { return String(describing: self) }
}
