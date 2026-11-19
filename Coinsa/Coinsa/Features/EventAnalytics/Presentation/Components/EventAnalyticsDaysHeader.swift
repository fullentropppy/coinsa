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

    private let homeAmount: Double
    private let homeCurrency: Currency
    private let locationAmount: Double?
    private let locationCurrency: Currency?
    private let amountTitle: LocalizedStringResource
    private let halfAmountTitle: LocalizedStringResource
    
    // MARK: - Инициализация

    /// Создает шапку вкладки дневной аналитики.
    /// - Parameter viewModel: ViewModel аналитики события.
    init(viewModel: EventAnalyticsViewModel) {
        let peak = viewModel.summaryChartPeakPoint
        self.init(
            homeAmount: peak?.homeAmount ?? 0,
            homeCurrency: viewModel.homeCurrency,
            locationAmount: peak?.locationAmount,
            locationCurrency: viewModel.locationCurrency
        )
    }

    /// Создает шапку с опорной суммой графика и ее половиной.
    /// - Parameters:
    ///   - homeAmount: Опорная сумма графика в домашней валюте.
    ///   - homeCurrency: Домашняя валюта события.
    ///   - locationAmount: Соответствующая сумма в валюте локации.
    ///   - locationCurrency: Дополнительная валюта при аналитике локации.
    ///   - amountTitle: Заголовок карточки опорной суммы.
    ///   - halfAmountTitle: Заголовок карточки половины опорной суммы.
    init(
        homeAmount: Double,
        homeCurrency: Currency,
        locationAmount: Double?,
        locationCurrency: Currency?,
        amountTitle: LocalizedStringResource = .amountExpensesDailyMax,
        halfAmountTitle: LocalizedStringResource = .analyticsAmountExpensesHalf
    ) {
        self.homeAmount = homeAmount
        self.homeCurrency = homeCurrency
        self.locationAmount = locationAmount
        self.locationCurrency = locationCurrency
        self.amountTitle = amountTitle
        self.halfAmountTitle = halfAmountTitle
    }
    
    // MARK: - Тело View
    
    var body: some View {
        VStack(spacing: ViewLayout.Summary.sectionSpacing) {
            HStack(spacing: ViewLayout.Summary.cardSpacing) {
                EventAmountCardView(
                    title: amountTitle,
                    homeAmount: homeAmount,
                    homeCurrency: homeCurrency,
                    locationAmount: locationAmount,
                    locationCurrency: locationCurrency
                )
                EventAmountCardView(
                    title: halfAmountTitle,
                    homeAmount: homeAmount / 2,
                    homeCurrency: homeCurrency,
                    locationAmount: locationAmount.map { $0 / 2 },
                    locationCurrency: locationCurrency
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
