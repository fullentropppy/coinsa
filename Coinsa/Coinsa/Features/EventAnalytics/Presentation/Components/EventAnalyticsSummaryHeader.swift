//
//  EventAnalyticsSummaryHeader.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.09.2026.
//

import SwiftUI

/// Шапка вкладки сводной аналитики расходов события.
struct EventAnalyticsSummaryHeader: View {
    // MARK: - Хранимые свойства

    private let viewModel: EventAnalyticsViewModel
    
    // MARK: - Инициализация

    /// Создает шапку вкладки сводной аналитики.
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
                        title: .amountBudget,
                        baseAmount: viewModel.eventSummaryData.budgetBaseAmount,
                        baseCurrency: viewModel.baseCurrency,
                        locationAmount: viewModel.eventSummaryData.budgetLocationAmount,
                        locationCurrency: viewModel.locationCurrency
                    )
                    EventAmountCardView(
                        title: .amountBudgetDaily,
                        baseAmount: viewModel.dailyBaseBudgetAmount,
                        baseCurrency: viewModel.baseCurrency,
                        locationAmount: viewModel.dailyLocationBudgetAmount,
                        locationCurrency: viewModel.locationCurrency
                    )
                }
                HStack {
                    EventAmountCardView(
                        title: .amountExpenses,
                        baseAmount: viewModel.eventSummaryData.expensesBaseAmount,
                        baseCurrency: viewModel.baseCurrency,
                        locationAmount: viewModel.eventSummaryData.expensesLocationAmount,
                        locationCurrency: viewModel.locationCurrency
                    )
                    EventAmountCardView(
                        title: .amountExpensesDaily,
                        baseAmount: viewModel.dailyBaseExpensesAmount,
                        baseCurrency: viewModel.baseCurrency,
                        locationAmount: viewModel.dailyLocationExpensesAmount,
                        locationCurrency: viewModel.locationCurrency
                    )
                }
                EventAmountBalanceView(
                    budgetBaseAmount: viewModel.eventSummaryData.budgetBaseAmount,
                    baseAmountBalance: viewModel.baseAmountBalance,
                    baseCurrency: viewModel.baseCurrency,
                    locationAmountBalance: viewModel.locationAmountBalance,
                    locationCurrency: viewModel.locationCurrency
                )
            }
        }
    }
}

// MARK: - Превью

private extension EventAnalyticsSummaryHeader {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder.builder().withScenario(.southKorea).withExpenses(true)
        let data = builder.buildData()
        let trip = builder.getTrip(from: data)
        let viewModel = TripDetailViewModel(trip: trip)

        return NavigationStack {
            List {
                EventAnalyticsSummaryHeader(viewModel: EventAnalyticsViewModel(data: viewModel.eventAnalyticsData))
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    EventAnalyticsSummaryHeader.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    EventAnalyticsSummaryHeader.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}

