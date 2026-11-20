//
//  View+EventExpensesMap.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.11.2026.
//

import SwiftUI

extension View {
    // MARK: - Публичные методы

    /// Добавляет кнопку и полноэкранную карту мест переданных трат.
    func eventExpensesMap(
        expenses: [Expense],
        screenContextSubtitle: String,
        navigationTitle: LocalizedStringResource = .analyticsExpensePlaces
    ) -> some View {
        modifier(EventExpensesMapModifier(
            expenses: expenses,
            screenContextSubtitle: screenContextSubtitle,
            navigationTitle: navigationTitle
        ))
    }
}

/// Открывает карту контекста, если среди его трат есть доступные места.
private struct EventExpensesMapModifier: ViewModifier {
    // MARK: - Состояние

    @State private var isShowingExpensesMap = false

    // MARK: - Свойства

    let expenses: [Expense]
    let screenContextSubtitle: String
    let navigationTitle: LocalizedStringResource

    // MARK: - Тело View

    func body(content: Content) -> some View {
        let hasExpensePlaces = ExpenseMapItem.hasItems(for: expenses)

        content
            .toolbar { [isShowingExpensesMap = $isShowingExpensesMap] in
                if hasExpensePlaces {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isShowingExpensesMap.wrappedValue = true
                        } label: {
                            Image(systemName: "map")
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $isShowingExpensesMap) { [expenses, screenContextSubtitle, navigationTitle] in
                EventExpensesMapView(
                    expenses: expenses,
                    screenContextSubtitle: screenContextSubtitle,
                    navigationTitle: navigationTitle
                )
            }
    }
}
