//
//  PercentInputField.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 17.04.2026.
//

import SwiftUI

struct PercentInputField: View {
    // MARK: - Свойства
    
    private let value: Binding<Double>
    private let focusedField: FocusState<NumericEditField?>.Binding
    private let focusId: NumericEditField
    private let font: Font
    
    // MARK: - Инициализация
    
    init(
        _ value: Binding<Double>,
        focusedField: FocusState<NumericEditField?>.Binding,
        focusId: NumericEditField,
        font: Font
    ) {
        self.value = value
        self.focusedField = focusedField
        self.focusId = focusId
        self.font = font
    }
    
    // MARK: - Тело View
    
    var body: some View {
        HStack {
            NumericInputField(
                value,
                focusedField: focusedField,
                focusId: focusId,
                fractionDigits: 2,
                font: font
            )
            Image(systemName: "percent")
                .fontWeight(.semibold)
                .imageScale(.small)
                .foregroundStyle(.secondary)
                .frame(width: 16)
        }
    }
}

// MARK: - Предопределенные варианты

extension PercentInputField {
    static func standard(
        _ value: Binding<Double>,
        focusedField: FocusState<NumericEditField?>.Binding,
        focusId: NumericEditField
    ) -> some View {
        PercentInputField(
            value,
            focusedField: focusedField,
            focusId: focusId,
            font: .body.monospacedDigit()
        )
    }
}

// MARK: - Превью

private extension PercentInputField {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        List {
            PercentInputFieldPreview()
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
    
    struct PercentInputFieldPreview: View {
        @State private var value: Double = 5.05
        @FocusState private var focusedField: NumericEditField?
        
        var body: some View {
            Section {
                PercentInputField(
                    $value,
                    focusedField: $focusedField,
                    focusId: .exchangeRate,
                    font: .body
                )
            }
            Section {
                PercentInputField.standard(
                    $value,
                    focusedField: $focusedField,
                    focusId: .exchangeRate
                )
            }
        }
    }
}

#Preview("Light - RU") {
    PercentInputField.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    PercentInputField.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
