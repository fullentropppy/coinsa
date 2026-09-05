//
//  EventAnalyticsDaysBody.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.08.2026.
//

import SwiftUI

/// Тело вкладки дневной аналитики расходов события.
struct EventAnalyticsDaysBody: View {
    // MARK: - Хранимые свойства

    private let viewModel: EventAnalyticsViewModel

    // MARK: - Инициализация

    /// Создает тело вкладки дневной аналитики.
    /// - Parameter viewModel: ViewModel аналитики события.
    init(viewModel: EventAnalyticsViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Тело View

    var body: some View {
        daysContent
    }

    // MARK: - Основной контент

    private var daysContent: some View {
        Group {
            dailyExpenseChartSection
            dailyExpensesSection
        }
    }

    // MARK: - Секции

    private var dailyExpenseChartSection: some View {
        Section {
            EventDailyExpenseChart(viewModel: viewModel)
        }
        .padding(.vertical, 12)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }

    private var dailyExpensesSection: some View {
        Section {
            ForEach(viewModel.summaryExpenseChartPoints) { point in
                if point.baseAmount > 0 {
                    dailyExpenseRow(point)
                }
            }
        }
    }

    // MARK: - Компоненты

    private func dailyExpenseRow(_ point: EventDailyExpenseAnalyticsData) -> some View {
        HStack {
            DateLabel(point.date.startOfDay, withTime: false, using: .utc)
                .frame(maxHeight: .infinity, alignment: .topLeading)
            Spacer()
            AmountStack(
                baseAmount: point.baseAmount,
                baseCurrency: viewModel.baseCurrency,
                expenseAmount: point.locationAmount,
                expenseCurrency: viewModel.locationCurrency
            )
        }
    }
}

// MARK: - Превью

private extension EventAnalyticsDaysBody {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder.builder().withScenario(.southKorea).withExpenses(true)
        let data = builder.buildData()
        let trip = builder.getTrip(from: data)
        let viewModel = TripDetailViewModel(trip: trip)

        return NavigationStack {
            List {
                EventAnalyticsDaysBody(viewModel: EventAnalyticsViewModel(data: viewModel.eventAnalyticsData))
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    EventAnalyticsDaysBody.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    EventAnalyticsDaysBody.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
