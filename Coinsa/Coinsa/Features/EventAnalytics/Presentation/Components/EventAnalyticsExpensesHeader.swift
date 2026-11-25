//
//  EventAnalyticsExpensesHeader.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.09.2026.
//

import SwiftUI

/// Общие суммы трат для вкладок категорий и локаций.
struct EventAnalyticsExpensesHeader: View {
    // MARK: - Хранимые свойства

    private let viewModel: EventAnalyticsViewModel
    private let excludesGeneralExpenses: Bool
    
    // MARK: - Инициализация

    /// Создает шапку с общей суммой трат и средним за день события.
    /// - Parameters:
    ///   - viewModel: ViewModel аналитики события.
    ///   - excludesGeneralExpenses: Показывать в шапке только траты локаций.
    init(viewModel: EventAnalyticsViewModel, excludesGeneralExpenses: Bool = false) {
        self.viewModel = viewModel
        self.excludesGeneralExpenses = excludesGeneralExpenses
    }
    
    // MARK: - Тело View
    
    var body: some View {
        HStack(spacing: ViewLayout.Summary.cardSpacing) {
            EventAmountCardView(
                title: .amountExpenses,
                homeAmount: excludesGeneralExpenses ? viewModel.locationsExpensesTotalHomeAmount : viewModel.expensesTotalHomeAmount,
                homeCurrency: viewModel.homeCurrency,
                locationAmount: viewModel.expensesTotalLocationAmount,
                locationCurrency: viewModel.locationCurrency
            )
            if viewModel.totalDays > 1 {
                EventAmountCardView(
                    title: .amountExpensesDaily,
                    homeAmount: excludesGeneralExpenses ? viewModel.locationsDailyHomeExpensesAmount : viewModel.dailyHomeExpensesAmount,
                    homeCurrency: viewModel.homeCurrency,
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
            EventAnalyticsExpensesHeader(
                viewModel: EventAnalyticsViewModel(data: viewModel.eventAnalyticsData)
            )
        }
    }
}

