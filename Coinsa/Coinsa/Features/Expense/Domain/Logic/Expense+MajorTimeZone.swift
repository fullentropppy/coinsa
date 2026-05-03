//
//  Expense+MajorTimeZone.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 19.04.2026.
//

extension Expense {
    /// Часовой пояс, в котором была совершена трата (из локации).
    var majorTimeZone: MajorTimeZone {
        location?.majorTimeZone ?? .defaultValue
    }
}
