//
//  AmountText.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.03.2026.
//

import SwiftUI

struct AmountText: View {
    // MARK: - Stored Properties
    
    private let amount: Double
    private let currency: Currency?
    private let style: ComponentStyle
    private let tint: Color?
    
    // MARK: - Initialization
    
    init(
        _ amount: Double,
        currency: Currency? = nil,
        style: ComponentStyle = .default,
        tint: Color? = nil
    ) {
        self.amount = amount
        self.currency = currency
        self.style = style
        self.tint = tint
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 4) {
            Text(amount, format: .number.precision(.fractionLength(2)))
                .font(styleFont)
                .foregroundStyle(resolvedColor)
            
            if let currency {
                CurrencyCodeText(currency, style: style, tint: tint)
            }
        }
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
    
    private var styleColor: Color {
        switch style {
        case .default, .primary:
            return .primary
        default:
            return .secondary
        }
    }
    
    private var resolvedColor: Color {
        tint ?? styleColor
    }
}

// MARK: - Previews

private extension AmountText {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let amount = 12345.67
        let currency = Currency.rub
        
        return VStack(spacing: 40) {
            VStack(spacing: 20) {
                AmountText(amount)
                AmountText(amount, style: .primary)
                AmountText(amount, style: .secondary)
                AmountText(amount, style: .tertiary)
            }
            
            VStack(spacing: 20) {
                AmountText(amount, tint: .accent)
                AmountText(amount, style: .primary, tint: .pink)
                AmountText(amount, style: .secondary, tint: .orange)
                AmountText(amount, style: .tertiary, tint: .green)
            }
            
            VStack(spacing: 20) {
                AmountText(amount, currency: currency)
                AmountText(amount, currency: currency, style: .primary)
                AmountText(amount, currency: currency, style: .secondary)
                AmountText(amount, currency: currency, style: .tertiary)
            }
            
            VStack(spacing: 20) {
                AmountText(amount, currency: currency, tint: .accent)
                AmountText(amount, currency: currency, style: .primary, tint: .pink)
                AmountText(amount, currency: currency, style: .secondary, tint: .orange)
                AmountText(amount, currency: currency, style: .tertiary, tint: .green)
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    AmountText.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    AmountText.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
