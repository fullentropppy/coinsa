//
//  EventAnalyticsCategoriesHeader.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.09.2026.
//

import SwiftUI

struct EventAnalyticsCategoriesHeader: View {
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
        HStack {
            EventAmountCardView(
                title: .amountExpenses,
                baseAmount: viewModel.expensesTotalBaseAmount,
                baseCurrency: viewModel.baseCurrency,
                locationAmount: viewModel.expensesTotalLocationAmount,
                locationCurrency: viewModel.locationCurrency
            )
            if viewModel.totalDays > 1 {
                EventAmountCardView(
                    title: .amountExpensesDaily,
                    baseAmount: viewModel.dailyBaseExpensesAmount,
                    baseCurrency: viewModel.baseCurrency,
                    locationAmount: viewModel.dailyLocationExpensesAmount,
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
            EventAnalyticsCategoriesHeader(
                viewModel: EventAnalyticsViewModel(data: viewModel.eventAnalyticsData)
            )
        }
    }
}

