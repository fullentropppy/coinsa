//
//  LocationGroupedExpensesBody.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.11.2026.
//

import SwiftUI

/// Список трат, отобранных предикатом и сгруппированных по локациям.
struct LocationGroupedExpensesBody: View {
    // MARK: - Хранимые свойства

    let navigationTitle: String
    let navigationSubtitle: String
    let sourceExpenses: [Expense]
    let predicate: (Expense) -> Bool

    // MARK: - Вычисляемые свойства

    @MainActor
    private var matchedLocations: [Location] {
        var seen: Set<Location.ID> = []
        var result: [Location] = []

        for expense in sourceExpenses where predicate(expense) {
            guard let location = expense.location else { continue }
            if seen.insert(location.id).inserted {
                result.append(location)
            }
        }

        return result.sorted(by: Self.compareLocations)
    }

    // MARK: - Тело View

    var body: some View {
        list
            .navigationTitle(navigationTitle)
            .navigationSubtitle(navigationSubtitle)
            .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Основной контент

    private var list: some View {
        List {
            if matchedLocations.isEmpty {
                EmptyStateView(icon: Expense.primaryIcon, title: .analyticsEmptyState)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(matchedLocations) { location in
                    Section {
                        ForEach(filteredExpenses(in: location)) { expense in
                            NavigationLink {
                                ExpenseDetailView(expense)
                            } label: {
                                ExpenseRowView(expense)
                            }
                        }
                    } header: {
                        Text(location.name)
                    }
                }
            }
        }
    }

    // MARK: - Вспомогательные методы

    private func filteredExpenses(in location: Location) -> [Expense] {
        (location.expenses ?? [])
            .filter(predicate)
            .sorted { $0.civilDateTime.storedDate > $1.civilDateTime.storedDate }
    }

    private static func compareLocations(_ lhs: Location, _ rhs: Location) -> Bool {
        if lhs.startPlainDate != rhs.startPlainDate {
            return lhs.startPlainDate > rhs.startPlainDate
        }
        if lhs.endPlainDate != rhs.endPlainDate {
            return lhs.endPlainDate > rhs.endPlainDate
        }
        return lhs.updatedAt > rhs.updatedAt
    }
}
