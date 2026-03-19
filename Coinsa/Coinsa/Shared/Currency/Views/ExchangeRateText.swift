//
//  ExchangeRateText.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 19.03.2026.
//

import SwiftUI

struct ExchangeRateText: View {
    // MARK: - Stored Properties
    
    private let fromCurrency: Currency
    private let toCurrency: Currency
    private let rate: Double
    private let style: ComponentStyle
    
    // MARK: - Initialization
    
    init(
        from fromCurrency: Currency,
        to toCurrency: Currency,
        rate: Double,
        style: ComponentStyle = .default
    ) {
        self.fromCurrency = fromCurrency
        self.toCurrency = toCurrency
        self.rate = rate
        self.style = style
    }
    
    // MARK: - Body
    
    var body: some View {
        Text("1 \(fromCurrency.code) = \(String(format: "%.4f", rate)) \(toCurrency.code)")
            .font(styleFont)
            .foregroundStyle(styleColor)
    }
    
    // MARK: - Components
    
    private var styleFont: Font {
        switch style {
        case .default:
            return .body
        case .primary:
            return .headline
        case .secondary:
            return .subheadline
        case .tertiary:
            return .footnote
        }
    }
    
    var styleColor: Color {
        switch style {
        case .default, .primary:
            return .primary
        default:
            return .secondary
        }
    }
}

// MARK: - Previews

private extension ExchangeRateText {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let from = Currency.usd
        let to = Currency.rub
        let rate = 80.0
        
        return VStack(spacing: 20) {
           ExchangeRateText(from: from, to: to, rate: rate)
           ExchangeRateText(from: from, to: to, rate: rate, style: .primary)
           ExchangeRateText(from: from, to: to, rate: rate, style: .secondary)
           ExchangeRateText(from: from, to: to, rate: rate, style: .tertiary)
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    ExchangeRateText.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    ExchangeRateText.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}

