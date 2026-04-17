//
//  EventAmountDifferenceView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 05.04.2026.
//

import SwiftUI

struct EventAmountDifferenceView: View {
    // MARK: - свойства
    
    private let baseAmountDifference: Double
    private let baseCurrency: Currency
    private let localAmountDifference: Double?
    private let localCurrency: Currency?
    
    // MARK: - Инициализация
    
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
    
    // MARK: - Тело View
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(.amountDifference)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Spacer()
            differenceInfo
            differenceIcon
        }
    }
    
    // MARK: - Компоненты
    
    private var differenceInfo: some View {
        Group {
            if let localAmountDifference, let localCurrency {
                Text(
                    .summaryExtendedDifference(
                        localAmountDifference: localAmountDifference.formatted(
                            .number.precision(.fractionLength(2))
                        ),
                        localCurrencyCode: localCurrency.code,
                        baseAmountDifference: baseAmountDifference.formatted(
                            .number.precision(.fractionLength(2))
                        ),
                        baseCurrencyCode: baseCurrency.code
                    )
                )
            } else {
                Text(
                    .summaryBaseDifference(
                        baseAmountDifference: baseAmountDifference.formatted(
                            .number.precision(.fractionLength(2))
                        ),
                        baseCurrencyCode: baseCurrency.code
                    )
                )
            }
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
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
            .imageScale(.small)
            .fontWeight(.semibold)
            .foregroundStyle(fillColor)
    }
}

// MARK: - Превью

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

