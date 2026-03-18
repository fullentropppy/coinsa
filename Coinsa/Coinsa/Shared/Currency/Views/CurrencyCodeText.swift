//
//  CurrencyCodeText.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.03.2026.
//

import SwiftUI

struct CurrencyCodeText: View {
    // MARK: - Stored Properties
    
    let currency: Currency
    let style: ComponentStyle
    let tint: Color?
    
    // MARK: - Initialization
    
    init(currency: Currency, style: ComponentStyle = .default, tint: Color? = nil) {
        self.currency = currency
        self.style = style
        self.tint = tint
    }
    
    // MARK: - Body
    
    var body: some View {
        Text(currency.code).font(styleFont).foregroundStyle(resolvedColor)
    }
    
    // MARK: - Components
    
    var styleFont: Font {
        switch style {
        case .default, .primary:
            return .body
        case .secondary:
            return .subheadline
        case .tertiary:
            return .footnote
        }
    }
    
    private var styleColor: Color {
        switch style {
        case .primary:
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

private extension CurrencyCodeText {
    static func preview(colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            CurrencyCodeText(currency: Currency.rub, style: .default)
            CurrencyCodeText(currency: Currency.usd, style: .primary)
            CurrencyCodeText(currency: Currency.eur, style: .secondary)
            CurrencyCodeText(currency: Currency.jpy, style: .tertiary)
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light") {
    CurrencyCodeText.preview(colorScheme: .light)
}

#Preview("Dark") {
    CurrencyCodeText.preview(colorScheme: .dark)
}
