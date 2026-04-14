//
//  EventAmountDifferenceView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 05.04.2026.
//

import SwiftUI

struct EventAmountDifferenceView: View {
    // MARK: - Stored Properties
    
    private let baseAmountDifference: Double
    private let baseCurrency: Currency
    private let localAmountDifference: Double?
    private let localCurrency: Currency?
    
    // MARK: - Initialization
    
    init(
        baseAmountDifference: Double,
        baseCurrency: Currency,
        localAmountDifference: Double? = nil,
        localCurrency: Currency? = nil
    ) {
        self.baseAmountDifference = baseAmountDifference
        self.baseCurrency = baseCurrency
        self.localAmountDifference = localAmountDifference
        self.localCurrency = localCurrency
    }
    
    // MARK: - Preview
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(.amountDifference).font(.footnote).foregroundStyle(.secondary)
            Spacer()
            differenceInfo
            differenceIcon
        }
    }
    
    private var differenceInfo: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            if let localAmountDifference, let localCurrency {
                AmountText.secondarySmall(localAmountDifference, currency: localCurrency)
                Text("•").foregroundStyle(.secondary)
            }
            AmountText.secondarySmall(baseAmountDifference, currency: baseCurrency)
        }
    }
    
    private var differenceIcon: some View {
        let icon: String
        let fillColor: Color
        
        if baseAmountDifference == 0 {
            icon = "chart.line.flattrend.xyaxis"
            fillColor = .yellow
        } else if baseAmountDifference > 0 {
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

// MARK: - Preview

private extension EventAmountDifferenceView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        Form {
            Section {
                EventAmountDifferenceView(
                    baseAmountDifference: -24600,
                    baseCurrency: .defaultCurrency,
                    localAmountDifference: -41000,
                    localCurrency: .jpy
                )
                EventAmountDifferenceView(
                    baseAmountDifference: 0,
                    baseCurrency: .defaultCurrency,
                    localAmountDifference: 0,
                    localCurrency: .jpy
                )
                EventAmountDifferenceView(
                    baseAmountDifference: 24600,
                    baseCurrency: .defaultCurrency,
                    localAmountDifference: 41000,
                    localCurrency: .jpy
                )
            }
            Section {
                EventAmountDifferenceView(baseAmountDifference: -24600, baseCurrency: .defaultCurrency)
                EventAmountDifferenceView(baseAmountDifference: 0, baseCurrency: .defaultCurrency)
                EventAmountDifferenceView(baseAmountDifference: 24600, baseCurrency: .defaultCurrency)
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    EventAmountDifferenceView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    EventAmountDifferenceView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}

