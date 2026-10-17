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
        viewModel.eventSummaryData.budgetBaseAmount > 0
    }
    
    // MARK: - Инициализация

    /// Создает шапку вкладки сводной аналитики.
    /// - Parameter viewModel: ViewModel аналитики события.
    init(viewModel: EventAnalyticsViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Тело View
    
    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 8) {
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
            HStack {
                EventAmountCardView(
                    title: .amountBudget,
                    baseAmount: viewModel.eventSummaryData.budgetBaseAmount,
                    baseCurrency: viewModel.baseCurrency,
                    locationAmount: viewModel.eventSummaryData.budgetLocationAmount,
                    locationCurrency: viewModel.locationCurrency
                )
                if viewModel.totalDays > 1 {
                    EventAmountCardView(
                        title: .amountBudgetDaily,
                        baseAmount: viewModel.dailyBaseBudgetAmount,
                        baseCurrency: viewModel.baseCurrency,
                        locationAmount: viewModel.dailyLocationBudgetAmount,
                        locationCurrency: viewModel.locationCurrency
                    )
                }
            }
        }
    }
    
    private var expensesContent: some View {
        HStack {
            EventAmountCardView(
                title: .amountExpenses,
                baseAmount: viewModel.eventSummaryData.expensesBaseAmount,
                baseCurrency: viewModel.baseCurrency,
                locationAmount: viewModel.eventSummaryData.expensesLocationAmount,
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
    
    @ViewBuilder
    private var balanceContent: some View {
        if hasBudget {
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

