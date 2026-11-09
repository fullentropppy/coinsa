//
//  EventDayExpensesView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.11.2026.
//

import SwiftUI

/// Экран списка всех трат за выбранный день с группировкой по локациям.
struct EventDayExpensesView: View {
    // MARK: - Хранимые свойства

    private let date: PlainDate
    private let data: EventCategoryAnalyticsData
    private let screenContextSubtitle: String

    // MARK: - Хранимые свойства
    
    private var navigationTitle: String {
        DateDisplayFormatter.format(
            date.startOfDay,
            showsTime: false,
            showsWeekday: true,
            using: .utc)
        .capitalized
    }
    
    // MARK: - Инициализация

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
        LocationGroupedExpensesBody(
            navigationTitle: navigationTitle,
            navigationSubtitle: screenContextSubtitle,
            sourceExpenses: data.expenses,
            predicate: { PlainDate($0.civilDateTime.storedDate, using: .utc) == date }
        )
    }
}

// MARK: - Превью

#Preview {
    let trip = PreviewGenerator.makeExampleTrip(includeLocations: true, includeExpenses: true)
    let viewModel = TripDetailViewModel(trip: trip)
    let analyticsViewModel = EventAnalyticsViewModel(data: viewModel.eventAnalyticsData)
    let day = analyticsViewModel.summaryExpenseChartPoints
        .last { $0.homeAmount > 0 }?
        .date

    NavigationStack {
        if let day {
            EventDayExpensesView(
                date: day,
                data: viewModel.eventAnalyticsData,
                screenContextSubtitle: trip.screenContextSubtitle
            )
        }
    }
}
