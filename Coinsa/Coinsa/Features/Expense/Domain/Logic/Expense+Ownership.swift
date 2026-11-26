//
//  Expense+Ownership.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.11.2026.
//

import Foundation
import SwiftData

extension Expense {
    // MARK: - Свойства

    /// Поездка единственного владельца; при неполных или противоречивых связях отсутствует.
    var owningTrip: Trip? {
        guard !isDeleted else { return nil }
        if let location {
            guard trip == nil, !location.isDeleted,
                  let trip = location.trip, !trip.isDeleted else { return nil }
            return trip
        }
        guard let trip, !trip.isDeleted else { return nil }
        return trip
    }

    /// Общая трата с доступной поездкой и без связи с локацией.
    var isGeneralExpense: Bool {
        location == nil && owningTrip != nil
    }
}

/// Снимок назначения и версии исходной траты для отложенного сохранения переноса.
struct ExpenseMoveContext {
    let expense: Expense
    let location: Location?
    let trip: Trip?
    let sourceUpdatedAt: Date
    let locationCurrency: Currency?

    /// Фиксирует назначение без изменения родителя исходной траты.
    /// - Parameters:
    ///   - expense: Переносимая трата.
    ///   - location: Целевая локация или nil для общих трат.
    ///   - trip: Поездка общих трат или nil для локации.
    init(_ expense: Expense, to location: Location? = nil, trip: Trip? = nil) {
        self.expense = expense
        self.location = location
        self.trip = trip
        sourceUpdatedAt = expense.updatedAt
        locationCurrency = location?.locationCurrency
    }
}
