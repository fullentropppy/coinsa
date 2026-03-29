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
            eventSymbol
            EventStatusLabel(data.status)
            Spacer()
            DateLabel(from: data.startDate, to: data.endDate, style: .tertiary)
            DurationLabel(days: data.durationDays, style: .tertiary)
        }
    }

    private var summaryContent: some View {
        VStack(spacing: 14) {
            HStack {
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

            HStack(alignment: .center) {
                Text("amount.difference").font(.footnote).foregroundStyle(.secondary)
                Spacer()
                AmountText(data.amountDifferenceLocal, currency: data.localCurrency, style: .tertiary)
                Text("•").foregroundStyle(.secondary)
                AmountText(data.amountDifferenceBase, currency: data.baseCurrency, style: .tertiary)
                differencySymbol
            }
        }
    }
    
    private var eventSymbol: some View {
        Image(systemName: "mappin.and.ellipse.circle.fill")
            .foregroundStyle(.teal)
            .imageScale(.large)
    }
    
    private var differencySymbol: some View {
        let symbolName = data.amountDifferenceBase >= 0 ? "arrowshape.up.circle.fill" : "arrowshape.down.circle.fill"
        let symbolTint = data.amountDifferenceBase >= 0 ? Color.green : Color.red
        
        return Image(systemName: symbolName)
            .foregroundStyle(symbolTint)
            .imageScale(.small)
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
            Text(title).font(.footnote).foregroundStyle(.secondary)
            AmountText(localAmount, currency: localCurrency)
            Divider()
            AmountText(baseAmount, currency: baseCurrency, style: .tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .glassEffect(.regular, in: .containerRelative)
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
