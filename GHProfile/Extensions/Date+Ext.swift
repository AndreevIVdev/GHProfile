//
//  Date+Ext.swift
//  GHProfile
//
//  Created by Ilya Andreev on 09.09.2021.
//

import Foundation

extension Date {
    
    func convertToMonthYearFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        return dateFormatter.string(from: self)
    }
}
