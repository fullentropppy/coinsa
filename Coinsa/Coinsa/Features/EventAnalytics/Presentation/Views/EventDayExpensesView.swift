//
//  EventDayExpensesView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.11.2026.
//

import SwiftData
import SwiftUI

/// Накопительный график и список трат выбранного дня с группировкой по локациям.
struct EventDayExpensesView: View {
    // MARK: - Хранимые свойства

    private let date: PlainDate
    private let data: EventCategoryAnalyticsData
    private let screenContextSubtitle: String

    // MARK: - Вычисляемые свойства
    
    private var navigationTitle: String {
        DateDisplayFormatter.format(
            date.startOfDay,
            showsTime: false,
            showsWeekday: true,
            using: .utc)
        .capitalized
    }
    
    // MARK: - Инициализация

    /// Создает аналитику трат за календарный день с контекстом исходного события.
    /// - Parameters:
    ///   - date: Выбранный календарный день.
    ///   - data: Траты и валюты исходного события.
    ///   - screenContextSubtitle: Подзаголовок исходной аналитики.
    init(
        date: PlainDate,
        data: EventCategoryAnalyticsData,
        screenContextSubtitle: String
    ) {
        self.date = date
        self.data = data
        self.screenContextSubtitle = screenContextSubtitle
    }

    // MARK: - Тело View

    var body: some View {
        let day = EventDayExpenseAnalyticsData(
            date: date,
            expenses: data.expenses,
            includesLocationAmount: data.locationCurrency != nil
        )

        List {
            Section {
                EventAnalyticsDaysHeader(
                    homeAmount: day.homeAmount,
                    homeCurrency: data.homeCurrency,
                    locationAmount: day.locationAmount,
                    locationCurrency: data.locationCurrency,
                    amountTitle: .analyticsAmountExpensesTotal,
                    halfAmountTitle: .analyticsAmountExpensesHalf
                )
            }

            Section {
                EventHourlyExpenseChart(data: day)
            }
            .padding(.vertical, ViewLayout.AnalyticsExpenseChart.sectionVerticalInset)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            LocationGroupedExpensesSections(
                viewModel: LocationGroupedExpensesViewModel(sourceExpenses: day.expenses, filter: .day(date)),
                showsLocationNames: data.locations != nil
            )
        }
        .navigationTitle(navigationTitle)
        .navigationSubtitle(screenContextSubtitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Превью

#Preview("For Trip") {
    @Previewable @State var preview = ExpenseMapPreviewData(forTrip: true)
    let day = preview.expenses.first.map { PlainDate($0.civilDateTime.storedDate) }

    NavigationStack {
        if let day {
            EventDayExpensesView(
                date: day,
                data: preview.analyticsData,
                screenContextSubtitle: preview.screenContextSubtitle
            )
        }
    }
    .modelContainer(preview.container)
    .environment(preview.settingsStore)
}

#Preview("For Location") {
    @Previewable @State var preview = ExpenseMapPreviewData()
    let day = preview.expenses.first.map { PlainDate($0.civilDateTime.storedDate) }

    NavigationStack {
        if let day {
            EventDayExpensesView(
                date: day,
                data: preview.analyticsData,
                screenContextSubtitle: preview.screenContextSubtitle
            )
        }
    }
    .modelContainer(preview.container)
    .environment(preview.settingsStore)
}
