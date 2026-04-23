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
    
    private var localAmountBalance: Double {
        if let planned = data.plannedLocalAmount, let actual = data.actualLocalAmount {
            planned - actual
        } else {
            0
        }
    }
    
    // MARK: - Инициализация
    
    init(
        data: EventSummaryData,
        showsHeader: Bool = true,
        showsAmounts: Bool = true,
        showsDifference: Bool = true,
        showsPlannedIfZero: Bool = false,
    ) {
        self.data = data
        self.showsHeader = showsHeader
        self.showsAmounts = showsAmounts
        self.showsAmountBalance = showsDifference
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

    private var headerContent: some View {
        HStack {
            data.badgeProvider.makeBadge()
            data.dateRangeProvider.status.makeBadge()
            Spacer()
            DateLabel.secondarySmall(
                from: data.dateRangeProvider.startDate,
                to: data.dateRangeProvider.endDate
            )
            CountLabel.daysSecondarySmall(data.dateRangeProvider.totalDays)
        }
    }

    private var amountsContent: some View {
        HStack {
            if showsPlannedAmount {
                EventAmountCardView(
                    title: .amountPlanned,
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
        let tripViewModel = TripDetailViewModel(
            trip: trip,
            baseCurrency: Currency.defaultValue
        )
        
        let location = builder.getLocation(from: data)
        let locationViewModel = LocationDetailViewModel(
            location: location,
            baseCurrency: Currency.defaultValue
        )
        
        return Form {
            Section {
                EventSummaryView(data: tripViewModel.eventHeaderData, showsAmounts: false, showsDifference: false)
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

