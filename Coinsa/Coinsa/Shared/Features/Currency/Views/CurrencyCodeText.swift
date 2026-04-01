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
    private let style: ComponentStyle
    private let tint: Color?
    
    // MARK: - Initialization
    
    init(_ currency: Currency, style: ComponentStyle = .default, tint: Color? = nil) {
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
        let currency = Currency.rub
        
        return VStack(spacing: 40){
            VStack(spacing: 20) {
                CurrencyCodeText(currency)
                CurrencyCodeText(currency, style: .primary)
                CurrencyCodeText(currency, style: .secondary)
                CurrencyCodeText(currency, style: .tertiary)
            }
            
            VStack(spacing: 20) {
                CurrencyCodeText(currency, tint: .accent)
                CurrencyCodeText(currency, style: .primary, tint: .pink)
                CurrencyCodeText(currency, style: .secondary, tint: .orange)
                CurrencyCodeText(currency, style: .tertiary, tint: .green)
            }
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
