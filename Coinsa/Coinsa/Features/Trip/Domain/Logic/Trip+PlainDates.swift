//
//  Trip+PlainDates.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.07.2026.
//

extension Trip {
    /// Календарная дата начала без времени и часового пояса.
    var startPlainDate: PlainDate {
        PlainDate(storedStartDate, using: .utc)
    }
    
    /// Календарная дата окончания без времени и часового пояса.
    var endPlainDate: PlainDate {
        PlainDate(storedEndDate, using: .utc)
    }
}
