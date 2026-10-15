//
//  NumericInputField.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.03.2026.
//

import SwiftUI

// MARK: - Публичные типы

/// Идентификаторы полей для управления фокусом в числовых вводах.
nonisolated enum NumericEditField: Hashable {
    case amount
    case exchangeRate
    case locationExchangeRate
    case exchangeAdjustment
    case budget
}

/// Кастомное поле для ввода числовых значений с форматированием и поддержкой фокуса.
struct NumericInputField: View {
    // MARK: - Свойства
    
    @State private var text: String = ""
    @Binding var value: Double
    
    private let focusedField: FocusState<NumericEditField?>.Binding
    private let focusID: NumericEditField
    private let fractionDigits: Int
    private let font: Font
    private let textAlignment: TextAlignment
    private let placeholder: String
    private let formatter: NumberFormatter
    
    // MARK: - Инициализация
    
    /// Создает поле для ввода чисел.
    /// - Parameters:
    ///   - value: Привязка к числовому значению.
    ///   - focusedField: Привязка к фокусированному полю.
    ///   - focusID: Уникальный идентификатор этого поля.
    ///   - fractionDigits: Количество знаков после запятой.
    ///   - font: Шрифт текста.
    ///   - textAlignment: Выравнивание текста.
    ///   - placeholder: Подсказка ввода (опционально). По умолчанию `nil`.
    ///   Если не указана, будет отображаться `0` с количеством нулей дробной части равным значению `fractionDigits`.
    init(
        _ value: Binding<Double>,
        focusedField: FocusState<NumericEditField?>.Binding,
        focusID: NumericEditField,
        fractionDigits: Int,
        font: Font,
        textAlignment: TextAlignment,
        placeholder: String? = nil
    ) {
        self._value = value
        self.focusedField = focusedField
        self.focusID = focusID
        self.fractionDigits = fractionDigits
        self.font = font
        self.textAlignment = textAlignment
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        formatter.usesGroupingSeparator = true
        
        self.formatter = formatter
        
        if let placeholder {
            self.placeholder = placeholder
        } else if fractionDigits == 0 {
            self.placeholder = "0"
        } else {
            let separator = formatter.decimalSeparator ?? ","
            let zeros = String(repeating: "0", count: fractionDigits)
            self.placeholder = "0\(separator)\(zeros)"
        }
    }
    
    // MARK: - Тело View
    
    var body: some View {
        TextField(placeholder, text: $text)
            .font(font)
            .focused(focusedField, equals: focusID)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(textAlignment)
            .onAppear { syncFromValue() }
            .onChange(of: value) {
                if focusedField.wrappedValue != focusID {
                    syncFromValue()
                }
            }
            .onChange(of: text) {
                if focusedField.wrappedValue == focusID {
                    syncValueFromText()
                }
            }
            .onChange(of: focusedField.wrappedValue) { oldID, newID in
                if oldID == focusID && newID != focusID {
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
    
    private func syncValueFromText() {
        value = parsedNumber(from: text)?.doubleValue ?? 0
    }

    private func commit() {
        let trimmed = text.trimmed
        
        guard !trimmed.isEmpty else {
            value = 0
            text = ""
            return
        }

        let number = parsedNumber(from: trimmed) ?? 0
        
        value = number.doubleValue
        text = formatter.string(from: number) ?? trimmed
    }
    
    private func parsedNumber(from input: String) -> NSNumber? {
        let groupingSeparator = formatter.groupingSeparator ?? ""
        let cleaned = input
            .trimmed
            .replacingOccurrences(of: groupingSeparator, with: "")
        
        return formatter.number(from: cleaned)
    }
}

// MARK: - Предопределенные варианты

extension NumericInputField {
    /// Стандартное числовое поле с моноширинными цифрами.
    /// - Parameters:
    ///   - value: Привязка к числовому значению.
    ///   - focusedField: Привязка к фокусированному полю.
    ///   - focusID: Уникальный идентификатор поля.
    ///   - fractionDigits: Количество знаков после запятой.
    /// - Returns: Настроенное поле ввода.
    static func standard(
        _ value: Binding<Double>,
        focusedField: FocusState<NumericEditField?>.Binding,
        focusID: NumericEditField,
        fractionDigits: Int
    ) -> some View {
        NumericInputField(
            value,
            focusedField: focusedField,
            focusID: focusID,
            fractionDigits: fractionDigits,
            font: .body.monospacedDigit(),
            textAlignment: .trailing
        )
    }
}

// MARK: - Превью

#Preview {
    @Previewable @State var amount: Double = 1234.56
    @Previewable @FocusState var focusedField: NumericEditField?
    
    List {
        Section {
            NumericInputField(
                $amount,
                focusedField: $focusedField,
                focusID: .amount,
                fractionDigits: 2,
                font: .body,
                textAlignment: .trailing
            )
        }
        Section {
            NumericInputField.standard(
                $amount,
                focusedField: $focusedField,
                focusID: .amount,
                fractionDigits: 2
            )
        }
    }
}
