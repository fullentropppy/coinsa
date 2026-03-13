//
//  CurrencyCodeText.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.03.2026.
//

import SwiftUI

struct CurrencyCodeText: View {
    // MARK: - Stored Properties
    
    let currencyOption: CurrencyOption
    
    // MARK: - Body
    
    var body: some View {
        Text(currencyOption.code).font(.headline).foregroundStyle(.secondary)
    }
}

// MARK: - Previews

private extension CurrencyCodeText {
    static func preview(colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            CurrencyCodeText(currencyOption: CurrencyOption.usd)
            CurrencyCodeText(currencyOption: CurrencyOption.eur)
            CurrencyCodeText(currencyOption: CurrencyOption.cny)
            CurrencyCodeText(currencyOption: CurrencyOption.aed)
            CurrencyCodeText(currencyOption: CurrencyOption.try)
            CurrencyCodeText(currencyOption: CurrencyOption.rub)
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
