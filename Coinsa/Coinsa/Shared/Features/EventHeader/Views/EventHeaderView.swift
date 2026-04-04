//
//  EventHeaderView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 29.03.2026.
//

import SwiftUI

struct EventHeaderView: View {
    // MARK: - Stored Properties

    let data: EventHeaderData
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
            BadgeView(fillColor: data.badgeColor, icon: data.badgeIcon)
            EventStatusLabel(data.status)
            Spacer()
            DateLabel.secondarySmall(from: data.startDate, to: data.endDate)
            CountLabel.daysSecondarySmall(data.days)
        }
    }

    private var summaryContent: some View {
        VStack(spacing: 14) {
            HStack {
                LocationAmountCardView(
                    title: .amountPlanned,
                    localAmount: data.plannedLocalAmount,
                    localCurrency: data.localCurrency,
                    baseAmount: data.plannedBaseAmount,
                    baseCurrency: data.baseCurrency
                )
                LocationAmountCardView(
                    title: .amountActual,
                    localAmount: data.actualLocalAmount,
                    localCurrency: data.localCurrency,
                    baseAmount: data.actualBaseAmount,
                    baseCurrency: data.baseCurrency
                )
            }
            HStack(alignment: .lastTextBaseline) {
                Text(.amountDifference).font(.footnote).foregroundStyle(.secondary)
                Spacer()
                differenceInfo
                differenceIcon
            }
        }
    }

    private var differenceInfo: some View {
        var parts: [String] = []
        if let amountDifferenceLocal = data.localAmountDifference,
           let localCurrency = data.localCurrency {
            parts.append("\(String(format: "%.2f", amountDifferenceLocal)) \(localCurrency.code)")
        }
        parts.append("\(String(format: "%.2f", data.baseAmountDifference)) \(data.baseCurrency.code)")
        let info = parts.joined(separator: "  •  ")
        
        return Text(info)
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
    
    private var differenceIcon: some View {
        let icon: String
        let fillColor: Color
        
        if data.baseAmountDifference == 0 {
            icon = "chart.line.flattrend.xyaxis"
            fillColor = .yellow
        } else if data.baseAmountDifference > 0 {
            icon = "chart.line.uptrend.xyaxis"
            fillColor = .green
        } else {
            icon = "chart.line.downtrend.xyaxis"
            fillColor = .red
        }
        
        return Image(systemName: icon)
            .fontWeight(.semibold)
            .foregroundStyle(fillColor)
            .imageScale(.small)
    }
}

private struct LocationAmountCardView: View {
    // MARK: - Stored Properties

    let title: LocalizedStringResource
    let localAmount: Double?
    let localCurrency: Currency?
    let baseAmount: Double
    let baseCurrency: Currency

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.footnote).foregroundStyle(.secondary)

            if let localAmount, let localCurrency {
                AmountText.standard(localAmount, currency: localCurrency)
                Divider()
                AmountText.secondarySmall(baseAmount, currency: baseCurrency)
            } else {
                AmountText.standard(baseAmount, currency: baseCurrency)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Preview

private extension EventHeaderData {
    static func makeTripPreview(
        showsSummary: Bool,
        locale: Locale,
        colorScheme: ColorScheme
    ) -> some View {
        let builder = PreviewBuilder.builder().withLocations(showsSummary)
        let data = builder.buildData()
        let trip = builder.getTrip(from: data)
        let viewModel = TripDetailViewModel(
            trip: trip,
            baseCurrency: Currency.defaultOption
        )

        return List {
            EventHeaderView(data: viewModel.eventHeaderData, showsSummary: showsSummary)
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
    
    static func makeLocationPreview(
        showsSummary: Bool,
        locale: Locale,
        colorScheme: ColorScheme
    ) -> some View {
        let builder = PreviewBuilder.builder().withExpenses(showsSummary)
        let data = builder.buildData()
        let location = builder.getLocation(from: data)
        let viewModel = LocationDetailViewModel(
            location: location,
            baseCurrency: Currency.defaultOption
        )

        return List {
            EventHeaderView(data: viewModel.eventHeaderData, showsSummary: showsSummary)
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Trip with summary. Light - RU") {
    EventHeaderData.makeTripPreview(
        showsSummary: true, locale: PreviewLocale.ru.locale, colorScheme: .light
    )
}

#Preview("Trip with summary. Dark - EN") {
    EventHeaderData.makeTripPreview(
        showsSummary: true, locale: PreviewLocale.en.locale, colorScheme: .dark
    )
}

#Preview("Trip without summary. Light - RU") {
    EventHeaderData.makeTripPreview(
        showsSummary: false, locale: PreviewLocale.ru.locale, colorScheme: .light
    )
}

#Preview("Trip without summary. Dark - EN") {
    EventHeaderData.makeTripPreview(
        showsSummary: false, locale: PreviewLocale.en.locale, colorScheme: .dark
    )
}

#Preview("Location with summary. Light - RU") {
    EventHeaderData.makeLocationPreview(
        showsSummary: true, locale: PreviewLocale.ru.locale, colorScheme: .light
    )
}

#Preview("Location with summary. Dark - EN") {
    EventHeaderData.makeLocationPreview(
        showsSummary: true, locale: PreviewLocale.en.locale, colorScheme: .dark
    )
}

#Preview("Location without summary. Light - RU") {
    EventHeaderData.makeLocationPreview(
        showsSummary: false, locale: PreviewLocale.ru.locale, colorScheme: .light
    )
}

#Preview("Location without summary. Dark - EN") {
    EventHeaderData.makeLocationPreview(
        showsSummary: false, locale: PreviewLocale.en.locale, colorScheme: .dark
    )
}
