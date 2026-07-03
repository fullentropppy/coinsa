//
//  Expense+CivilDateTime.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.07.2026.
//

extension Expense {
    /// Дата и время без часового пояса в UTC-календаре.
    var civilDateTime: CivilDateTime {
        CivilDateTime(storedDate, using: .utc)
    }
}
