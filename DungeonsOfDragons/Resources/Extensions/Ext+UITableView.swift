//
//  Ext+UITableView.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import UIKit

extension UITableView {
    func registeringCellsInTable(_ cells: UITableViewCell.Type...) {
        cells.forEach { cell in
            self.register(cell, forCellReuseIdentifier: String(describing: cell))
        }
    }
}
