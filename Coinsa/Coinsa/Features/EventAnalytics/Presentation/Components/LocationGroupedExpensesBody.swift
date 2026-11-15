//
//  LocationGroupedExpensesBody.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.11.2026.
//

import SwiftUI

/// Список трат с фильтром по значению и группировкой по локациям.
struct LocationGroupedExpensesBody: View, Equatable {
    // MARK: - Хранимые свойства

    let navigationTitle: String
    let navigationSubtitle: String
    let viewModel: LocationGroupedExpensesViewModel
    var showsLocationNames = true

    // MARK: - Тело View

    var body: some View {
        list
            .navigationTitle(navigationTitle)
            .navigationSubtitle(navigationSubtitle)
            .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Основной контент

    private var list: some View {
        let groups = viewModel.expenseGroups

        return List {
            if groups.isEmpty {
                EmptyStateView(icon: Expense.primaryIcon, title: .analyticsEmptyStateTitle)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(groups) { group in
                    Section {
                        ForEach(group.expenses) { expense in
                            NavigationLink {
                                ExpenseDetailView(expense)
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
}
