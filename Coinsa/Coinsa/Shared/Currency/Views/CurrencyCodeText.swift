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
    let style: ComponentStyle
    
    // MARK: - Initialization
    
    init(currencyOption: CurrencyOption, style: ComponentStyle = .default) {
        self.currencyOption = currencyOption
        self.style = style
    }
    
    // MARK: - Body
    
    var body: some View {
        Text(currencyOption.code).font(codeFont).foregroundStyle(codeColor)
    }
    
    // MARK: - Components
    
    var codeFont: Font {
        switch style {
        case .default, .primary:
            return .body
        case .secondary:
            return .subheadline
        case .tertiary:
            return .footnote
        }
    }
    
    var codeColor: Color {
        switch style {
        case .primary:
            return .primary
        default:
            return .secondary
        }
    }
}

// MARK: - Previews

private extension CurrencyCodeText {
    static func preview(colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            CurrencyCodeText(currencyOption: CurrencyOption.rub, style: .default)
            CurrencyCodeText(currencyOption: CurrencyOption.usd, style: .primary)
            CurrencyCodeText(currencyOption: CurrencyOption.eur, style: .secondary)
            CurrencyCodeText(currencyOption: CurrencyOption.jpy, style: .tertiary)
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
