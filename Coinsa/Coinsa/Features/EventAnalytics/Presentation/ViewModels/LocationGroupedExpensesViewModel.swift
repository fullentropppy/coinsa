//
//  LocationGroupedExpensesViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 16.11.2026.
//

import Foundation

/// Отбор и группировка трат аналитики с однократной подготовкой ключей сортировки.
struct LocationGroupedExpensesViewModel: Equatable {
    enum Filter: Equatable {
        case subcategory(ExpenseSubcategory)
        case day(PlainDate)

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
        let id: UUID
        let location: Location
        let expenses: [Expense]
    }

    private struct LocationSortEntry {
        let group: Group
        let startDate: PlainDate
        let endDate: PlainDate
        let updatedAt: Date
        let id: String
    }

    let sourceExpenses: [Expense]
    let filter: Filter

    var expenseGroups: [Group] {
        let grouped = Dictionary(grouping: sourceExpenses.filter(filter.includes)) { $0.location?.id }

        let entries: [LocationSortEntry] = grouped.values.compactMap { expenses in
            guard let location = expenses.first?.location else { return nil }

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
                group: Group(id: location.id, location: location, expenses: sortedExpenses),
                startDate: location.startPlainDate,
                endDate: location.endPlainDate,
                updatedAt: location.updatedAt,
                id: location.id.uuidString
            )
        }

        return entries.sorted {
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
