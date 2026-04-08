//
//  DateRangeProviding.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 05.03.2026.
//

import Foundation

// MARK: - Protocol

protocol DateRangeProviding {
    var startDate: Date { get }
    var endDate: Date { get }
}

// MARK: - Default Implementation

extension DateRangeProviding {
    var durationInDays: Int {
        let difference = (endDate.timeIntervalSince(startDate) / 86400).rounded()
        return difference == 0 ? 1 : Int(difference)
    }
    
    var range: ClosedRange<Date> {
        startDate...endDate
    }
}
