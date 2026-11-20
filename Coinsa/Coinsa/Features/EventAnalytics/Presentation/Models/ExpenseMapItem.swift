//
//  ExpenseMapItem+Coordinator.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.11.2026.
//

import MapKit
import SwiftData
import SwiftUI

/// Снимок координаты и оформления траты для обновления меток карты.
struct ExpenseMapItem: Identifiable, Equatable {
    // MARK: - Хранимые свойства

    let id: UUID
    let coordinate: Coordinate
    let icon: String
    let color: Color

    // MARK: - Публичные методы

    static func hasItems(for expenses: [Expense]) -> Bool {
        expenses.contains { validCoordinate(for: $0) != nil }
    }

    static func items(for expenses: [Expense]) -> [ExpenseMapItem] {
        expenses.compactMap { expense in
            guard let coordinate = validCoordinate(for: expense) else { return nil }

            return ExpenseMapItem(
                id: expense.id,
                coordinate: coordinate,
                icon: expense.subcategory.secondaryIcon,
                color: expense.subcategory.accentColor
            )
        }
    }

    // MARK: - Приватные методы

    private static func validCoordinate(for expense: Expense) -> Coordinate? {
        guard !expense.isDeleted,
              expense.modelContext != nil,
              let coordinate = expense.coordinate,
              coordinate.latitude.isFinite,
              coordinate.longitude.isFinite,
              CLLocationCoordinate2DIsValid(coordinate.coreLocationCoordinate) else {
            return nil
        }

        return coordinate
    }
}
