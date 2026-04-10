//
//  Date+Comparison.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 10.04.2026.
//

import Foundation

extension Date {
    // MARK: - Computed Properties
    
    var isYesterday: Bool {
        self.startOfDay == Date().yesterday.startOfDay
    }
    
    var isToday: Bool {
        self.startOfDay == Date().startOfDay
    }
    
    var isTomorrow: Bool {
        self.startOfDay == Date().tomorrow.startOfDay
    }
    
    // MARK: - Public Methods
    
    func isSameDay(as other: Date) -> Bool {
        self.startOfDay == other.startOfDay
    }
    
    func isBetween(_ start: Date, and end: Date) -> Bool {
        self.startOfDay >= start && self.endOfDay <= end
    }
}
