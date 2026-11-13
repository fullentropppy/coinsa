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
    
    // MARK: - Вычисляемые свойства
    
    private var hasBudget: Bool {
        viewModel.eventSummaryData.budgetHomeAmount > 0
    }
    
    // MARK: - Инициализация

    /// Создает шапку вкладки сводной аналитики.
    /// - Parameter viewModel: ViewModel аналитики события.
    init(viewModel: EventAnalyticsViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Тело View
    
    var body: some View {
        VStack(spacing: ViewLayout.Summary.sectionSpacing) {
            VStack(spacing: ViewLayout.Summary.cardSpacing) {
                budgetContent
                expensesContent
            }
            balanceContent
        }
    }
    
    // MARK: - Компоненты
    
    @ViewBuilder
    private var budgetContent: some View {
        if hasBudget {
            HStack(spacing: ViewLayout.Summary.cardSpacing) {
                EventAmountCardView(
                    title: .amountBudget,
                    homeAmount: viewModel.eventSummaryData.budgetHomeAmount,
                    homeCurrency: viewModel.homeCurrency,
                    locationAmount: viewModel.eventSummaryData.budgetLocationAmount,
                    locationCurrency: viewModel.locationCurrency
                )
                if viewModel.totalDays > 1 {
                    EventAmountCardView(
                        title: .amountBudgetDaily,
                        homeAmount: viewModel.dailyHomeBudgetAmount,
                        homeCurrency: viewModel.homeCurrency,
                        locationAmount: viewModel.dailyLocationBudgetAmount,
                        locationCurrency: viewModel.locationCurrency
                    )
                }
            }
        }
    }
    
    private var expensesContent: some View {
        HStack(spacing: ViewLayout.Summary.cardSpacing) {
            EventAmountCardView(
                title: .amountExpenses,
                homeAmount: viewModel.eventSummaryData.expensesHomeAmount,
                homeCurrency: viewModel.homeCurrency,
                locationAmount: viewModel.eventSummaryData.expensesLocationAmount,
                locationCurrency: viewModel.locationCurrency
            )
            if viewModel.totalDays > 1 {
                EventAmountCardView(
                    title: .amountExpensesDaily,
                    homeAmount: viewModel.dailyHomeExpensesAmount,
                    homeCurrency: viewModel.homeCurrency,
                    locationAmount: viewModel.dailyLocationExpensesAmount,
                    locationCurrency: viewModel.locationCurrency
                )
            }
        }
    }
    
    @ViewBuilder
    private var balanceContent: some View {
        if hasBudget {
            EventAmountBalanceView(
                budgetHomeAmount: viewModel.eventSummaryData.budgetHomeAmount,
                homeAmountBalance: viewModel.homeAmountBalance,
                homeCurrency: viewModel.homeCurrency,
                locationAmountBalance: viewModel.locationAmountBalance,
                locationCurrency: viewModel.locationCurrency
            )
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
            EventAnalyticsSummaryHeader(
                viewModel: EventAnalyticsViewModel(data: viewModel.eventAnalyticsData)
            )
        }
    }
}

