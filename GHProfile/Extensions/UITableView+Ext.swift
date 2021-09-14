//
//  UITableView+Ext.swift
//  GHProfile
//
//  Created by Ilya Andreev on 10.09.2021.
//

import UIKit

extension UITableView {
    
    func removeExcessCells() {
        tableFooterView = UIView(frame: .zero)
    }
    
    func reloadDataOnMainThread() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
}
