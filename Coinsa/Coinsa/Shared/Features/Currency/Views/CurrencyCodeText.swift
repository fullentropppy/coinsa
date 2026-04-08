//
//  CurrencyCodeText.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.03.2026.
//

import SwiftUI

struct CurrencyCodeText: View {
    // MARK: - Stored Properties
    
    private let currency: Currency
    private let font: Font
    private let color: Color
    
    // MARK: - Initialization
    
    init(
        _ currency: Currency,
        font: Font = .body,
        color: Color = .secondary
    ) {
        self.currency = currency
        self.font = font
        self.color = color
    }
    
    // MARK: - Body
    
    var body: some View {
        Text(currency.code)
            .font(font)
            .foregroundStyle(color)
    }
}

// MARK: - Presets

extension CurrencyCodeText {
    static func standard(_ currency: Currency) -> some View {
        CurrencyCodeText(currency, color: .secondary)
    }
    
    static func secondarySmall(_ currency: Currency) -> some View {
        CurrencyCodeText(currency, font: .footnote, color: .secondary)
    }
}

// MARK: - Previews

private extension CurrencyCodeText {
    static func makePreview(colorScheme: ColorScheme) -> some View {
        let currency = Currency.rub
        
        return VStack(spacing: 40) {
            VStack(spacing: 20) {
                CurrencyCodeText(currency)
                CurrencyCodeText(currency, font: .footnote, color: .accent)
            }
            VStack(spacing: 20) {
                CurrencyCodeText.standard(currency)
                CurrencyCodeText.secondarySmall(currency)
            }
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light") {
    CurrencyCodeText.makePreview(colorScheme: .light)
}

#Preview("Dark") {
    CurrencyCodeText.makePreview(colorScheme: .dark)
}
