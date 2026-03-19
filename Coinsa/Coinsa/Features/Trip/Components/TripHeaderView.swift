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
                TripAmountCardView(
                    title: "amount.planned",
                    amount: data.plannedAmount,
                    currency: data.currency,
                    tint: .blue
                )
                TripAmountCardView(
                    title: "amount.actual",
                    amount: data.actualAmount,
                    currency: data.currency,
                    tint: .yellow
                )
            }
            
            TripAmountCardView(
                title: "amount.difference",
                amount: data.amountDifference,
                currency: data.currency,
                tint: differenceTint
            )
        }
    }
}

struct TripAmountCardView: View {
    // MARK: - Stored Properties

    let title: LocalizedStringKey
    let amount: Double
    let currency: Currency
    let tint: Color

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            AmountText(amount, currency: currency)
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
            let viewModel = TripDetailViewModel(
                trip: trip,
                baseCurrency: Currency.defaultOption
            )
            
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
