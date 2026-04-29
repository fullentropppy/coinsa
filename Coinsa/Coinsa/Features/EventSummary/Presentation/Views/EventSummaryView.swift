//
//  EventSummaryView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 29.03.2026.
//

import SwiftUI

struct EventSummaryView: View {
    // MARK: - Хранимые свойства

    private let data: EventSummaryData
    private let showsHeader: Bool
    private let showsAmounts: Bool
    private let showsAmountBalance: Bool
    private let showsPlannedIfZero: Bool
    
    // MARK: - Вычисляемые свойства

    private var showsPlannedAmount: Bool {
        data.plannedBaseAmount > 0 || showsPlannedIfZero
    }
    
    private var baseAmountBalance: Double {
        data.plannedBaseAmount - data.actualBaseAmount
    }
    
    private var localAmountBalance: Double? {
        if let planned = data.plannedLocalAmount, let actual = data.actualLocalAmount {
            planned - actual
        } else {
            nil
        }
    }
    
    // MARK: - Инициализация
    
    init(
        data: EventSummaryData,
        showsHeader: Bool = true,
        showsAmounts: Bool = true,
        showsAmountBalance: Bool = true,
        showsPlannedIfZero: Bool = false,
    ) {
        self.data = data
        self.showsHeader = showsHeader
        self.showsAmounts = showsAmounts
        self.showsAmountBalance = showsAmountBalance
        self.showsPlannedIfZero = showsPlannedIfZero
    }
    
    // MARK: - Тело View

    var body: some View {
        if !showsHeader && !showsAmounts && !showsAmountBalance {
            EmptyView()
        } else {
            VStack(spacing: 14) {
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
            HStack {
                badgeProvider.makeBadge()
                dateRangeProvider.status.makeBadge()
                Spacer()
                DateLabel.secondarySmall(
                    from: dateRangeProvider.startDate,
                    to: dateRangeProvider.endDate
                )
                CountLabel.daysSecondarySmall(dateRangeProvider.totalDays)
            }
        }
    }

    private var amountsContent: some View {
        HStack {
            if showsPlannedAmount {
                EventAmountCardView(
                    title: .amountPlan,
                    baseAmount: data.plannedBaseAmount,
                    baseCurrency: data.baseCurrency,
                    localAmount: data.plannedLocalAmount,
                    localCurrency: data.localCurrency
                )
            }
            EventAmountCardView(
                title: .amountActual,
                baseAmount: data.actualBaseAmount,
                baseCurrency: data.baseCurrency,
                localAmount: data.actualLocalAmount,
                localCurrency: data.localCurrency
            )
        }
    }
    
    @ViewBuilder
    private var amountBalanceContent: some View {
        if showsPlannedAmount {
            VStack {
                EventAmountBalanceView(
                    plannedBaseAmount: data.plannedBaseAmount,
                    baseAmountBalance: baseAmountBalance,
                    baseCurrency: data.baseCurrency,
                    localAmountBalance: localAmountBalance,
                    localCurrency: data.localCurrency
                )
            }
        }
    }
}

// MARK: - Превью

private extension EventSummaryData {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder.builder()
        let data = builder.buildData()
        
        let trip = builder.getTrip(from: data)
        let tripViewModel = TripDetailViewModel(trip: trip)
        
        let location = builder.getLocation(from: data)
        let locationViewModel = LocationDetailViewModel(location: location)
        
        return Form {
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
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    EventSummaryData.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    EventSummaryData.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}

