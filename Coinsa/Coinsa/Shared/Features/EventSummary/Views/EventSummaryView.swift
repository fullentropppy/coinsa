//
//  EventSummaryView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 29.03.2026.
//

import SwiftUI

struct EventSummaryView: View {
    // MARK: - Stored Properties

    let data: EventSummaryData
    let showsHeader: Bool
    let showsAmounts: Bool
    let showsDifference: Bool
    
    // MARK: - Computed Properties
    
    private var days: Int {
        let difference = data.endDate.days(from: data.startDate)
        return difference == 0 ? 1 : Int(difference)
    }
    
    private var baseAmountDifference: Double {
        data.plannedBaseAmount - data.actualBaseAmount
    }
    
    private var localAmountDifference: Double {
        if let planned = data.plannedLocalAmount, let actual = data.actualLocalAmount {
            planned - actual
        } else {
            0
        }
    }
    
    // MARK: - Initialization
    
    init(
        data: EventSummaryData,
        showsHeader: Bool = true,
        showsAmounts: Bool = true,
        showsDifference: Bool = true
    ) {
        self.data = data
        self.showsHeader = showsHeader
        self.showsAmounts = showsAmounts
        self.showsDifference = showsDifference
    }
    
    // MARK: - Body

    var body: some View {
        if !showsHeader && !showsAmounts && !showsDifference {
            EmptyView()
        } else {
            VStack(spacing: 14) {
                if showsHeader {
                    headerContent
                }
                if showsAmounts {
                    amountsContent
                }
                if showsDifference {
                    differenceContent
                }
            }
        }
    }

    // MARK: - Components

    private var headerContent: some View {
        HStack {
            BadgeView(fillColor: data.badgeColor, icon: data.badgeIcon)
            data.status.makeBadge()
            Spacer()
            DateLabel.secondarySmall(from: data.startDate, to: data.endDate)
            CountLabel.daysSecondarySmall(days)
        }
    }

    private var amountsContent: some View {
        HStack {
            EventAmountCardView(
                title: .amountPlanned,
                baseAmount: data.plannedBaseAmount,
                baseCurrency: data.baseCurrency,
                localAmount: data.plannedLocalAmount,
                localCurrency: data.localCurrency
            )
            EventAmountCardView(
                title: .amountActual,
                baseAmount: data.actualBaseAmount,
                baseCurrency: data.baseCurrency,
                localAmount: data.actualLocalAmount,
                localCurrency: data.localCurrency
            )
        }
    }
    
    private var differenceContent: some View {
        EventAmountDifferenceView(
            baseAmountDifference: baseAmountDifference,
            baseCurrency: data.baseCurrency,
            localAmountDifference: localAmountDifference,
            localCurrency: data.localCurrency
        )
    }
}

// MARK: - Preview

private extension EventSummaryData {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder.builder()
        let data = builder.buildData()
        
        let trip = builder.getTrip(from: data)
        let tripViewModel = TripDetailViewModel(
            trip: trip,
            baseCurrency: Currency.defaultCurrency
        )
        
        let location = builder.getLocation(from: data)
        let locationViewModel = LocationDetailViewModel(
            location: location,
            baseCurrency: Currency.defaultCurrency
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

