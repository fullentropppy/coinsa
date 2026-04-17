//
//  NumericInputField.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.03.2026.
//

import SwiftUI

// MARK: - Публичные типы для поля ввода

enum NumericEditField: Hashable {
    case amount
    case exchangeRate
    case exchangeAdjustment
    case test(String)
    case budget(String)
}

struct NumericInputField: View {
    // MARK: - Свойства
    
    @State private var text: String = ""
    @Binding var value: Double
    
    private let focusedField: FocusState<NumericEditField?>.Binding
    private let focusId: NumericEditField
    private let fractionDigits: Int
    private let font: Font
    
    // MARK: - Вычисляемые свойсва
    
    private var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        formatter.usesGroupingSeparator = true
        return formatter
    }

    private var placeholder: String {
        guard fractionDigits > 0 else {
            return "0"
        }
        
        let separator = formatter.decimalSeparator ?? ","
        let zeros = String(repeating: "0", count: fractionDigits)
        
        return "0\(separator)\(zeros)"
    }
    
    // MARK: - Инициализация
    
    init(
        _ value: Binding<Double>,
        focusedField: FocusState<NumericEditField?>.Binding,
        focusId: NumericEditField,
        fractionDigits: Int,
        font: Font
    ) {
        self._value = value
        self.focusedField = focusedField
        self.focusId = focusId
        self.fractionDigits = fractionDigits
        self.font = font
    }
    
    // MARK: - Тело View
    
    var body: some View {
        TextField(placeholder, text: $text)
            .font(font)
            .focused(focusedField, equals: focusId)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .onAppear { syncFromValue() }
            .onChange(of: value) {
                if focusedField.wrappedValue != focusId {
                    syncFromValue()
                }
            }
            .onChange(of: focusedField.wrappedValue) { oldId, newId in
                if oldId == focusId && newId != focusId {
                    commit()
                }
            }
            .onSubmit {
                commit()
            }
    }

    // MARK: - Приватные методы
    
    private func syncFromValue() {
        text = value == 0 ? "" : formatter.string(from: NSNumber(value: value)) ?? ""
    }

    private func commit() {
        let trimmed = text.trimmed
        
        guard !trimmed.isEmpty else {
            value = 0
            text = ""
            return
        }

        let groupingSeparator = formatter.groupingSeparator ?? ""
        let cleaned = trimmed.replacingOccurrences(of: groupingSeparator, with: "")
        let number = formatter.number(from: cleaned) ?? 0
        
        value = number.doubleValue
        text = formatter.string(from: number) ?? cleaned
    }
}

// MARK: - Предопределенные варианты

extension NumericInputField {
    static func standard(
        _ value: Binding<Double>,
        focusedField: FocusState<NumericEditField?>.Binding,
        focusId: NumericEditField,
        fractionDigits: Int
    ) -> some View {
        NumericInputField(
            value,
            focusedField: focusedField,
            focusId: focusId,
            fractionDigits: fractionDigits,
            font: .body.monospacedDigit()
        )
    }
}

// MARK: - Превью

private extension NumericInputField {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        List {
            NumericInputFieldPreview()
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
    
    private struct NumericInputFieldPreview: View {
        @State private var amount: Double = 1234.56
        @FocusState private var focusedField: NumericEditField?

        var body: some View {
            Section {
                NumericInputField(
                    $amount,
                    focusedField: $focusedField,
                    focusId: .amount,
                    fractionDigits: 2,
                    font: .body
                )
            }
            Section {
                NumericInputField.standard(
                    $amount,
                    focusedField: $focusedField,
                    focusId: .amount,
                    fractionDigits: 2
                )
            }
        }
    }
}

#Preview("Light - RU") {
    NumericInputField.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    NumericInputField.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
