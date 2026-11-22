//
//  ExpenseCopyDateMetadata.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 22.11.2026.
//

import Foundation

/// Снимок времени исходной траты для копии с неизмененными гражданскими компонентами.
struct ExpenseCopyDateMetadata {
    // MARK: - Свойства

    let civilDateTime: CivilDateTime
    let actualDate: Date?
    let timeZoneID: String?

    // MARK: - Инициализация

    /// Сохраняет исходные сведения о времени, включая отсутствующие исторические значения.
    /// - Parameter expense: Копируемая трата.
    init(_ expense: Expense) {
        civilDateTime = expense.civilDateTime
        actualDate = expense.actualDate
        timeZoneID = expense.timeZoneID
    }
}
