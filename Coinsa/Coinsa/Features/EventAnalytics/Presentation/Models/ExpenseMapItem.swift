//
//  ExpenseMapItem.swift
//  Coinsa
//

import MapKit
import SwiftData
import SwiftUI

/// Снимок координаты и оформления траты для обновления меток карты.
struct ExpenseMapItem: Identifiable, Equatable {
    let id: UUID
    let coordinate: Coordinate
    let icon: String
    let color: Color

    static func items(for expenses: [Expense]) -> [ExpenseMapItem] {
        expenses.compactMap { expense in
            guard !expense.isDeleted,
                  expense.modelContext != nil,
                  let coordinate = expense.coordinate,
                  coordinate.latitude.isFinite,
                  coordinate.longitude.isFinite,
                  CLLocationCoordinate2DIsValid(coordinate.coreLocationCoordinate) else {
                return nil
            }

            return ExpenseMapItem(
                id: expense.id,
                coordinate: coordinate,
                icon: expense.subcategory.primaryIcon,
                color: expense.subcategory.accentColor
            )
        }
    }
}
