//
//  TripDetailHeaderView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.03.2026.
//

import SwiftUI

struct TripHeaderView: View {
    // MARK: - Stored Properties

    let data: TripDetailHeaderData
    let showsSummary: Bool

    // MARK: - Computed Properties
    
    private var differenceTint: Color {
        data.amountDifference >= 0 ? .green : .red
    }
    
    // MARK: - Body

    var body: some View {
        VStack(spacing: 14) {
            headerContent
            if showsSummary {
                summaryContent
            }
        }
    }
    
    // MARK: - Components
    
    private var headerContent: some View {
        HStack {
            EventStatusLabelView(status: data.status)
            Spacer()
            EventIntervalView(startDate: data.startDate, endDate: data.endDate)
            Spacer()
            EventDurationView(days: data.durationDays)
        }
    }
    
    private var summaryContent: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                TripAmountCardView(
                    title: "trip.detail.summary.planned",
                    amount: data.plannedAmount,
                    currencyCode: data.currencyCode,
                    tint: .blue
                )
                TripAmountCardView(
                    title: "trip.detail.summary.actual",
                    amount: data.actualAmount,
                    currencyCode: data.currencyCode,
                    tint: .yellow
                )
            }
            
            TripAmountCardView(
                title: "trip.detail.summary.difference",
                amount: data.amountDifference,
                currencyCode: data.currencyCode,
                tint: differenceTint
            )
        }
    }
    
}

// MARK: - Preview

private extension TripHeaderView {
    static func preview(
        withSummary: Bool,
        locale: Locale,
        colorScheme: ColorScheme
    ) -> some View {
        List {
            let builder = PreviewBuilder.builder()
            let data = builder.buildData()
            let trip = builder.getTrip(from: data)
            let viewModel = TripDetailViewModel(trip: trip)
            
            TripHeaderView(
                data: viewModel.headerData,
                showsSummary: withSummary
            )
            .environment(\.locale, locale)
            .preferredColorScheme(colorScheme)
        }
    }
}

#Preview("Light - RU") {
    TripHeaderView.preview(withSummary: true, locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    TripHeaderView.preview(withSummary: true, locale: PreviewLocale.en.locale, colorScheme: .dark)
}

#Preview("No Summary. Light - RU") {
    TripHeaderView.preview(withSummary: false, locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("No Summary. Dark - EN") {
    TripHeaderView.preview(withSummary: false, locale: PreviewLocale.en.locale, colorScheme: .dark)
}
