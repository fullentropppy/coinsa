//
//  EventAnalyticsDaysHeader.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.09.2026.
//

import SwiftUI

/// Шапка вкладки дневной аналитики расходов события.
struct EventAnalyticsDaysHeader: View {
    // MARK: - Хранимые свойства

    private let viewModel: EventAnalyticsViewModel
    
    // MARK: - Инициализация

    /// Создает шапку вкладки дневной аналитики.
    /// - Parameter viewModel: ViewModel аналитики события.
    init(viewModel: EventAnalyticsViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Тело View
    
    var body: some View {
        Section {
            VStack(spacing: 14) {
                HStack {
                    EventAmountCardView(
                        title: .amountExpensesDailyMax,
                        baseAmount: viewModel.maxDailyBaseExpenseAmount,
                        baseCurrency: viewModel.baseCurrency,
                        locationAmount: viewModel.maxDailyLocationExpenseAmount,
                        locationCurrency: viewModel.locationCurrency
                    )
                    EventAmountCardView(
                        title: .amountExpensesDailyAverage,
                        baseAmount: viewModel.averageDailyBaseExpenseAmount,
                        baseCurrency: viewModel.baseCurrency,
                        locationAmount: viewModel.averageDailyLocationExpenseAmount,
                        locationCurrency: viewModel.locationCurrency
                    )
                }
            }
        }
    }
}

// MARK: - Превью

private extension EventAnalyticsDaysHeader {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder.builder().withScenario(.southKorea).withExpenses(true)
        let data = builder.buildData()
        let trip = builder.getTrip(from: data)
        let viewModel = TripDetailViewModel(trip: trip)

        return NavigationStack {
            List {
                EventAnalyticsDaysHeader(viewModel: EventAnalyticsViewModel(data: viewModel.eventAnalyticsData))
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    EventAnalyticsDaysHeader.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    EventAnalyticsDaysHeader.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}

