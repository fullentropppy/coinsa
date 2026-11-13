//
//  EventSubcategoryExpensesView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.11.2026.
//

import SwiftUI

/// Экран списка всех трат выбранной подкатегории с группировкой по локациям.
struct EventSubcategoryExpensesView: View {
    // MARK: - Хранимые свойства

    private let subcategory: ExpenseSubcategory
    private let data: EventCategoryAnalyticsData
    private let screenContextSubtitle: String

    // MARK: - Инициализация

    /// Создает список трат выбранной подкатегории с контекстом исходного события.
    init(
        subcategory: ExpenseSubcategory,
        data: EventCategoryAnalyticsData,
        screenContextSubtitle: String
    ) {
        self.subcategory = subcategory
        self.data = data
        self.screenContextSubtitle = screenContextSubtitle
    }

    // MARK: - Тело View

    var body: some View {
        LocationGroupedExpensesBody(
            navigationTitle: String(localized: subcategory.localizedResource),
            navigationSubtitle: screenContextSubtitle,
            sourceExpenses: data.expenses,
            predicate: { $0.subcategory == subcategory }
        )
    }
}

// MARK: - Превью

#Preview {
    let trip = PreviewGenerator.makeExampleTrip(includeLocations: true, includeExpenses: true)
    let viewModel = TripDetailViewModel(trip: trip)
    let analyticsViewModel = EventAnalyticsViewModel(data: viewModel.eventAnalyticsData)
    let category = analyticsViewModel
        .displayedSlicesSortedByAmount(for: .categories)
        .first?
        .category ?? .defaultValue
    let subcategory = analyticsViewModel
        .displayedSubcategorySlicesSortedByAmount(for: category)
        .first?
        .subcategory

    NavigationStack {
        if let subcategory {
            EventSubcategoryExpensesView(
                subcategory: subcategory,
                data: viewModel.eventAnalyticsData,
                screenContextSubtitle: trip.screenContextSubtitle
            )
        }
    }
}
