//
//  CurrencyCodeText.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.03.2026.
//

import SwiftUI

/// Текстовое представление кода валюты.
struct CurrencyCodeText: View {
    // MARK: - Свойства
    
    private let currency: Currency
    private let font: Font
    private let color: Color
    
    // MARK: - Инициализация
    
    /// Создаёт текстовое представление кода валюты.
    /// - Parameters:
    ///   - currency: Валюта.
    ///   - font: Шрифт текста. По умолчанию `.body`.
    ///   - color: Цвет текста. По умолчанию `.secondary`.
    init(
        _ currency: Currency,
        font: Font = .body,
        color: Color = .secondary
    ) {
        self.currency = currency
        self.font = font
        self.color = color
    }
    
    // MARK: - Тело View
    
    var body: some View {
        Text(currency.code)
            .font(font)
            .foregroundStyle(color)
    }
}

// MARK: - Предопределенные варианты

extension CurrencyCodeText {
    /// Стандартный код валюты (полужирный моноширинный шрифт).
    static func standard(_ currency: Currency) -> some View {
        CurrencyCodeText(currency, font: .body.monospaced().weight(.medium), color: .secondary)
    }
    
    /// Компактный код валюты (мелкий полужирный моноширинный шрифт).
    static func secondarySmall(_ currency: Currency) -> some View {
        CurrencyCodeText(currency, font: .footnote.monospaced().weight(.medium), color: .secondary)
    }
}

// MARK: - Превью

private extension CurrencyCodeText {
    static func makePreview(colorScheme: ColorScheme) -> some View {
        let currency = Currency.defaultValue
        
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
