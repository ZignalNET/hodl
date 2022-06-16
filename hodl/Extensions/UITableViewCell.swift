//
//  UITableViewCell.swift
//  Part of my local repo
//
//  Created by Emmanuel Adigun on 2021/06/23.
//  Copyright © 2021. All rights reserved.
//

import UIKit

extension UITableViewCell: Reusable {
    @objc func onConfigureCell(cell: UITableViewCell, model: Any) {}
    @objc func onSelectedCell(index: Int, cell: UITableViewCell, model: Any) {}
}

