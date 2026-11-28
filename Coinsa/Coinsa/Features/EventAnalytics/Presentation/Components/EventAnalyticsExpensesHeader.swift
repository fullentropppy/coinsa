//
//  EventAnalyticsExpensesHeader.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.09.2026.
//

import SwiftUI

/// Общие суммы трат и средние за день для выбранного раздела аналитики.
struct EventAnalyticsExpensesHeader: View {
    // MARK: - Хранимые свойства

    private let summary: EventAnalyticsExpensesSummary
    
    // MARK: - Инициализация

    /// Создает шапку с общей суммой трат и средним за день события.
    /// - Parameters:
    ///   - viewModel: ViewModel аналитики события.
    ///   - excludesGeneralExpenses: Показывать в шапке только траты локаций.
    init(viewModel: EventAnalyticsViewModel, excludesGeneralExpenses: Bool = false) {
        self.summary = EventAnalyticsExpensesSummary(
            homeAmount: excludesGeneralExpenses ? viewModel.locationsExpensesTotalHomeAmount : viewModel.expensesTotalHomeAmount,
            homeCurrency: viewModel.homeCurrency,
            locationAmount: viewModel.expensesTotalLocationAmount,
            locationCurrency: viewModel.locationCurrency,
            dailyHomeAmount: excludesGeneralExpenses ? viewModel.locationsDailyHomeExpensesAmount : viewModel.dailyHomeExpensesAmount,
            dailyLocationAmount: viewModel.dailyLocationExpensesAmount,
            totalDays: viewModel.totalDays
        )
    }

    /// Создает шапку из итогов выбранной категории или подкатегории.
    /// - Parameter summary: Суммы выбранных трат и средние за день исходного события.
    init(summary: EventAnalyticsExpensesSummary) {
        self.summary = summary
    }
    
    // MARK: - Тело View
    
    var body: some View {
        HStack(spacing: ViewLayout.Summary.cardSpacing) {
            EventAmountCardView(
                title: .amountExpenses,
                homeAmount: summary.homeAmount,
                homeCurrency: summary.homeCurrency,
                locationAmount: summary.locationAmount,
                locationCurrency: summary.locationCurrency
            )
            if summary.totalDays > 1 {
                EventAmountCardView(
                    title: .amountExpensesDaily,
                    homeAmount: summary.dailyHomeAmount,
                    homeCurrency: summary.homeCurrency,
                    locationAmount: summary.dailyLocationAmount,
                    locationCurrency: summary.locationCurrency
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

