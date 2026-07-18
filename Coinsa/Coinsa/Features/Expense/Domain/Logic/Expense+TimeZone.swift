//
//  Expense+TimeZone.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 18.07.2026.
//

import Foundation

extension Expense {
    // Часовой пояс (из идентификатора).
    var timeZone: TimeZone {
        TimeZone(identifier: timeZoneId ?? "") ?? .current
    }
}
