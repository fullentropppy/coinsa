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
                    baseAmount: viewModel.middleDailyBaseExpenseAmount,
                    baseCurrency: viewModel.baseCurrency,
                    locationAmount: viewModel.middleDailyLocationExpenseAmount,
                    locationCurrency: viewModel.locationCurrency
                )
            }
        }
    }
}

// MARK: - Превью

#Preview {
    let viewModel = TripDetailViewModel(
        trip: PreviewGenerator.makeExampleTrip(includeLocations: true, includeExpenses: true)
    )

    NavigationStack {
        List {
            EventAnalyticsDaysHeader(
                viewModel: EventAnalyticsViewModel(data: viewModel.eventAnalyticsData)
            )
        }
    }
}
