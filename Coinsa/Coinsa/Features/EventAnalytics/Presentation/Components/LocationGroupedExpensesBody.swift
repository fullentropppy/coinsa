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
    var showsLocationNames = true

    // MARK: - Вычисляемые свойства

    @MainActor
    private var expenseGroups: [(location: Location, expenses: [Expense])] {
        let grouped = Dictionary(grouping: sourceExpenses.filter(predicate)) { $0.location?.id }

        return grouped.values.compactMap { expenses in
            guard let location = expenses.first?.location else { return nil }
            let sortedExpenses = expenses.sorted {
                if $0.civilDateTime.storedDate != $1.civilDateTime.storedDate {
                    return $0.civilDateTime.storedDate > $1.civilDateTime.storedDate
                }
                return $0.id.uuidString < $1.id.uuidString
            }
            return (location: location, expenses: sortedExpenses)
        }
        .sorted { Self.compareLocations($0.location, $1.location) }
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
        let groups = expenseGroups

        return List {
            if groups.isEmpty {
                EmptyStateView(icon: Expense.primaryIcon, title: .analyticsEmptyStateTitle)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(groups, id: \.location.id) { group in
                    Section {
                        ForEach(group.expenses) { expense in
                            NavigationLink {
                                AnalyticsDestinationView {
                                    ExpenseDetailView(expense)
                                }
                            } label: {
                                ExpenseRowView(expense)
                            }
                        }
                    } header: {
                        if showsLocationNames {
                            Text(group.location.name)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Вспомогательные методы

    private static func compareLocations(_ lhs: Location, _ rhs: Location) -> Bool {
        if lhs.startPlainDate != rhs.startPlainDate {
            return lhs.startPlainDate > rhs.startPlainDate
        }
        if lhs.endPlainDate != rhs.endPlainDate {
            return lhs.endPlainDate > rhs.endPlainDate
        }
        if lhs.updatedAt != rhs.updatedAt {
            return lhs.updatedAt > rhs.updatedAt
        }
        return lhs.id.uuidString < rhs.id.uuidString
    }
}
