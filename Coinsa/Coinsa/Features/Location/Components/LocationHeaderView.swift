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
            EventStatusLabel(data.status)
            Spacer()
            DateLabel(from: data.startDate, to: data.endDate, style: .secondary)
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

struct LocationAmountCardView: View {
    // MARK: - Stored Properties
    
    let title: LocalizedStringKey
    let localAmount: Double
    let localCurrency: Currency
    let baseAmount: Double
    let baseCurrency: Currency
    let tint: Color
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            AmountText(baseAmount, currency: baseCurrency)
            AmountText(localAmount, currency: localCurrency, style: .secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(tint.opacity(0.4).gradient)
        )
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
