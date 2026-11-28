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
    private let summary: EventAnalyticsExpensesSummary
    private let showsLocationNames: Bool
    private let screenContextSubtitle: String

    // MARK: - Инициализация

    /// Создает список трат выбранной подкатегории с контекстом исходного события.
    /// - Parameters:
    ///   - subcategory: Подкатегория для отбора трат.
    ///   - expenses: Траты только выбранной подкатегории.
    ///   - summary: Итоги подкатегории за полный период исходного события.
    ///   - showsLocationNames: Показывать названия локаций в заголовках секций поездки.
    ///   - screenContextSubtitle: Подзаголовок исходной аналитики.
    init(
        subcategory: ExpenseSubcategory,
        expenses: [Expense],
        summary: EventAnalyticsExpensesSummary,
        showsLocationNames: Bool,
        screenContextSubtitle: String
    ) {
        self.subcategory = subcategory
        self.expenses = expenses
        self.summary = summary
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
            showsLocationNames: showsLocationNames,
            expensesSummary: summary
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
    let categoryViewModel = analyticsViewModel.subcategoryViewModels()[category]
    let subcategory = categoryViewModel?
        .displayedSlices
        .first?
        .subcategory

    NavigationStack {
        if let subcategory, let categoryViewModel {
            EventSubcategoryExpensesView(
                subcategory: subcategory,
                expenses: preview.expenses.filter { $0.subcategory == subcategory },
                summary: categoryViewModel.expensesSummary(for: subcategory),
                showsLocationNames: true,
                screenContextSubtitle: preview.screenContextSubtitle
            )
        }
    }
    .modelContainer(preview.container)
    .environment(preview.settingsStore)
}
