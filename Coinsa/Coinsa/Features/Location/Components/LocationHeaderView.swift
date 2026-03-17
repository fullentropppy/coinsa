//
//  LocationHeaderView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.03.2026.
//

import SwiftUI

struct LocationHeaderView: View {
    // MARK: - Stored Properties

    let data: LocationDetailHeaderData
    let showsSummary: Bool
    
    // MARK: - Computed Properties

    private var differenceTint: Color {
        data.amountDifferenceBase >= 0 ? .green : .red
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 14) {
            headerContent
            summaryContent
        }
    }

    // MARK: - Components

    private var headerContent: some View {
        HStack {
            EventStatusLabel(status: data.status)
            Spacer()
            IntervalText(startDate: data.startDate, endDate: data.endDate)
            Spacer()
            DurationLabel(days: data.durationDays)
        }
    }

    private var summaryContent: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                LocationAmountCardView(
                    title: "amount.planned",
                    localAmount: data.plannedAmountLocal,
                    localCurrency: data.localCurrency,
                    baseAmount: data.plannedAmountBase,
                    baseCurrency: data.baseCurrency,
                    tint: .blue
                )
                LocationAmountCardView(
                    title: "amount.actual",
                    localAmount: data.actualAmountLocal,
                    localCurrency: data.localCurrency,
                    baseAmount: data.actualAmountBase,
                    baseCurrency: data.baseCurrency,
                    tint: .yellow
                )
            }

            LocationAmountCardView(
                title: "amount.difference",
                localAmount: data.amountDifferenceLocal,
                localCurrency: data.localCurrency,
                baseAmount: data.amountDifferenceBase,
                baseCurrency: data.baseCurrency,
                tint: differenceTint
            )
        }
    }
}

// MARK: - Preview

private extension LocationHeaderView {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        List {
            let builder = PreviewBuilder.builder()
            let data = builder.buildData()
            let location = builder.getLocation(from: data)
            let viewModel = LocationDetailViewModel(
                location: location,
                baseCurrency: Currency.defaultOption
            )

            LocationHeaderView(data: viewModel.headerData, showsSummary: true)
                .environment(\.locale, locale)
                .preferredColorScheme(colorScheme)
        }
    }
}

#Preview("Light - RU") {
    LocationHeaderView.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    LocationHeaderView.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
