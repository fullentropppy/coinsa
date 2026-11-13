//
//  EventSummaryView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 29.03.2026.
//

import SwiftUI

/// Комплексное представление сводки события.
struct EventSummaryView: View {
    // MARK: - Хранимые свойства
    
    private let data: EventSummaryData
    private let showsHeader: Bool
    private let showsAmounts: Bool
    private let showsAmountBalance: Bool
    private let showsBudgetIfZero: Bool
    
    // MARK: - Вычисляемые свойства
    
    private var showsBudgetAmount: Bool {
        data.budgetHomeAmount > 0 || showsBudgetIfZero
    }
    
    // MARK: - Инициализация
    
    /// Создает представление сводки события.
    /// - Parameters:
    ///   - data: Данные для отображения.
    ///   - showsHeader: Показывать заголовок. По умолчанию `true`.
    ///   - showsAmounts: Показывать карточки сумм. По умолчанию `true`.
    ///   - showsAmountBalance: Показывать баланс. По умолчанию `true`.
    ///   - showsBudgetIfZero: Показывать плановые суммы при нуле. По умолчанию `false`.
    init(
        data: EventSummaryData,
        showsHeader: Bool = true,
        showsAmounts: Bool = true,
        showsAmountBalance: Bool = true,
        showsBudgetIfZero: Bool = false
    ) {
        self.data = data
        self.showsHeader = showsHeader
        self.showsAmounts = showsAmounts
        self.showsAmountBalance = showsAmountBalance
        self.showsBudgetIfZero = showsBudgetIfZero
    }
    
    // MARK: - Тело View
    
    var body: some View {
        if !showsHeader && !showsAmounts && !showsAmountBalance {
            EmptyView()
        } else {
            VStack(spacing: ViewLayout.Summary.sectionSpacing) {
                if showsHeader {
                    headerContent
                }
                if showsAmounts {
                    amountsContent
                }
                
                if showsAmountBalance {
                    amountBalanceContent
                }
            }
        }
    }
    
    // MARK: - Компоненты
    
    @ViewBuilder
    private var headerContent: some View {
        if let badgeProvider = data.badgeProvider, let dateRangeProvider = data.dateRangeProvider {
            HStack(spacing: ViewLayout.Row.metadataSpacing) {
                Badge(style: .combined(
                    icon: badgeProvider.secondaryIcon,
                    badge: dateRangeProvider.status.localizedResource,
                    fill: dateRangeProvider.status.accentColor)
                )
                Spacer()
                DateLabel.secondarySmall(
                    from: dateRangeProvider.startPlainDate,
                    to: dateRangeProvider.endPlainDate
                )
                DotDivider.secondarySmall()
                CountLabel.daysSecondarySmall(dateRangeProvider.totalDays)
            }
        }
    }
    
    private var amountsContent: some View {
        HStack(spacing: ViewLayout.Summary.cardSpacing) {
            if showsBudgetAmount {
                EventAmountCardView(
                    title: data.budgetTitle,
                    homeAmount: data.budgetHomeAmount,
                    homeCurrency: data.homeCurrency,
                    locationAmount: data.budgetLocationAmount,
                    locationCurrency: data.locationCurrency
                )
            }
            EventAmountCardView(
                title: .amountExpenses,
                homeAmount: data.expensesHomeAmount,
                homeCurrency: data.homeCurrency,
                locationAmount: data.expensesLocationAmount,
                locationCurrency: data.locationCurrency
            )
        }
    }
    
    @ViewBuilder
    private var amountBalanceContent: some View {
        if showsBudgetAmount {
            EventAmountBalanceView(
                budgetHomeAmount: data.budgetHomeAmount,
                homeAmountBalance: data.homeAmountBalance,
                homeCurrency: data.homeCurrency,
                locationAmountBalance: data.locationAmountBalance,
                locationCurrency: data.locationCurrency
            )
        }
    }
}

// MARK: - Превью

#Preview {
    let tripViewModel = TripDetailViewModel(
        trip: PreviewGenerator.makeExampleTrip(includeLocations: true, includeExpenses: true)
    )
    let locationViewModel = LocationDetailViewModel(
        location: PreviewGenerator.makeExampleLocation(includeExpenses: true)
    )
    
    Form {
        Section {
            EventSummaryView(data: tripViewModel.eventHeaderData, showsAmounts: false, showsAmountBalance: false)
        }
        Section {
            EventSummaryView(data: tripViewModel.eventHeaderData)
        }
        Section {
            EventSummaryView(data: locationViewModel.eventHeaderData)
        }
        Section {
            EventSummaryView(data: locationViewModel.eventHeaderData, showsHeader: false)
        }
    }
}
