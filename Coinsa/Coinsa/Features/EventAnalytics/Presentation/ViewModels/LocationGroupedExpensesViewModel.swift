//
//  LocationGroupedExpensesViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 16.11.2026.
//

import Foundation

/// Отбор и группировка трат аналитики с однократной подготовкой ключей сортировки.
struct LocationGroupedExpensesViewModel: Equatable {
    // MARK: - Внутренние типы

    enum Filter: Equatable {
        // MARK: - Значения

        case subcategory(ExpenseSubcategory)
        case day(PlainDate)

        // MARK: - Публичные методы

        func includes(_ expense: Expense) -> Bool {
            switch self {
            case .subcategory(let subcategory):
                expense.subcategory == subcategory
            case .day(let date):
                PlainDate(expense.civilDateTime.storedDate, using: .utc) == date
            }
        }
    }

    struct Group: Identifiable {
        // MARK: - Хранимые свойства

        let id: UUID
        let location: Location?
        let expenses: [Expense]
    }

    private struct LocationSortEntry {
        // MARK: - Хранимые свойства

        let group: Group
        let startDate: PlainDate
        let endDate: PlainDate
        let updatedAt: Date
        let id: String
    }

    // MARK: - Хранимые свойства

    let sourceExpenses: [Expense]
    let filter: Filter

    // MARK: - Вычисляемые свойства

    var expenseGroups: [Group] {
        let grouped = Dictionary(grouping: sourceExpenses.filter(filter.includes)) { $0.location?.id ?? $0.owningTrip?.id }

        let entries: [LocationSortEntry] = grouped.values.compactMap { expenses in
            guard let first = expenses.first, let trip = first.owningTrip else { return nil }
            let location = first.location

            let entries = expenses.map { expense in
                (expense: expense, date: expense.civilDateTime.storedDate, id: expense.id.uuidString)
            }
            let sortedExpenses = entries.sorted {
                if $0.date != $1.date {
                    return $0.date > $1.date
                }
                return $0.id < $1.id
            }.map(\.expense)

            return LocationSortEntry(
                group: Group(id: location?.id ?? trip.id, location: location, expenses: sortedExpenses),
                startDate: location?.startPlainDate ?? trip.startPlainDate,
                endDate: location?.endPlainDate ?? trip.endPlainDate,
                updatedAt: location?.updatedAt ?? trip.updatedAt,
                id: (location?.id ?? trip.id).uuidString
            )
        }

        return entries.sorted {
            if ($0.group.location == nil) != ($1.group.location == nil) {
                return $0.group.location == nil
            }
            if $0.startDate != $1.startDate {
                return $0.startDate > $1.startDate
            }
            if $0.endDate != $1.endDate {
                return $0.endDate > $1.endDate
            }
            if $0.updatedAt != $1.updatedAt {
                return $0.updatedAt > $1.updatedAt
            }
            return $0.id < $1.id
        }
        .map(\.group)
    }
}
