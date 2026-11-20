//
//  EventSubcategoryExpensesView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.11.2026.
//

import SwiftData
import SwiftUI

/// Экран списка всех трат выбранной подкатегории с группировкой по локациям.
struct EventSubcategoryExpensesView: View {
    // MARK: - Хранимые свойства

    private let subcategory: ExpenseSubcategory
    private let expenses: [Expense]
    private let showsLocationNames: Bool
    private let screenContextSubtitle: String

    // MARK: - Инициализация

    /// Создает список трат выбранной подкатегории с контекстом исходного события.
    /// - Parameters:
    ///   - subcategory: Подкатегория для отбора трат.
    ///   - expenses: Траты только выбранной подкатегории.
    ///   - showsLocationNames: Показывать названия локаций в заголовках секций поездки.
    ///   - screenContextSubtitle: Подзаголовок исходной аналитики.
    init(
        subcategory: ExpenseSubcategory,
        expenses: [Expense],
        showsLocationNames: Bool,
        screenContextSubtitle: String
    ) {
        self.subcategory = subcategory
        self.expenses = expenses
        self.showsLocationNames = showsLocationNames
        self.screenContextSubtitle = screenContextSubtitle
    }

    // MARK: - Тело View

    var body: some View {
        LocationGroupedExpensesBody(
            navigationTitle: String(localized: subcategory.localizedResource),
            navigationSubtitle: screenContextSubtitle,
            viewModel: LocationGroupedExpensesViewModel(
                sourceExpenses: expenses,
                filter: .subcategory(subcategory)
            ),
            showsLocationNames: showsLocationNames
        )
        .equatable()
        .eventExpensesMap(
            expenses: expenses,
            screenContextSubtitle: screenContextSubtitle,
            navigationTitle: .analyticsExpensePlacesNavigationTitleSubcategory(
                subcategoryName: String(localized: subcategory.localizedResource)
            )
        )
    }
}

// MARK: - Превью

#Preview {
    @Previewable @State var preview = ExpenseMapPreviewData(forTrip: true)
    let analyticsViewModel = EventAnalyticsViewModel(data: preview.analyticsData)
    let category = analyticsViewModel
        .displayedSlicesSortedByAmount(for: .categories)
        .first?
        .category ?? .defaultValue
    let subcategory = analyticsViewModel
        .subcategoryViewModels(amountMode: .total)[category]?
        .displayedSlices
        .first?
        .subcategory

    NavigationStack {
        if let subcategory {
            EventSubcategoryExpensesView(
                subcategory: subcategory,
                expenses: preview.expenses.filter { $0.subcategory == subcategory },
                showsLocationNames: true,
                screenContextSubtitle: preview.screenContextSubtitle
            )
        }
    }
    .modelContainer(preview.container)
    .environment(preview.settingsStore)
}
