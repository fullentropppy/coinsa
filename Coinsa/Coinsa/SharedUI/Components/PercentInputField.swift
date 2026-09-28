//
//  PercentInputField.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 17.04.2026.
//

import SwiftUI

/// Поле для ввода процентных значений с иконкой процента.
struct PercentInputField: View {
    // MARK: - Свойства
    
    private let value: Binding<Double>
    private let focusedField: FocusState<NumericEditField?>.Binding
    private let focusId: NumericEditField
    private let font: Font
    
    // MARK: - Инициализация
    
    /// Создает поле для ввода процентов.
    /// - Parameters:
    ///   - value: Привязка к числовому значению.
    ///   - focusedField: Привязка к фокусированному полю.
    ///   - focusId: Уникальный идентификатор поля.
    ///   - font: Шрифт текста.
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
                font: font,
                textAlignment: .trailing
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
    /// Стандартное поле для ввода процентов с моноширинными цифрами.
    /// - Parameters:
    ///   - value: Привязка к числовому значению.
    ///   - focusedField: Привязка к фокусированному полю.
    ///   - focusId: Уникальный идентификатор поля.
    /// - Returns: Настроенное поле ввода.
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

#Preview {
    @Previewable @State var value: Double = 5.05
    @Previewable @FocusState var focusedField: NumericEditField?

    List {
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
