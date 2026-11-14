//
//  NumericInputField.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.03.2026.
//

import SwiftUI

/// Кастомное поле для ввода числовых значений с форматированием и поддержкой фокуса.
struct NumericInputField: View {
    // MARK: - Свойства
    
    @State private var state: DecimalInputState
    @State private var textFieldText: String = ""
    @State private var hasUserChanges = false
    @Binding private var value: Double
    
    private let focusedField: FocusState<NumericEditField?>.Binding
    private let focusID: NumericEditField
    private let font: Font
    private let textAlignment: TextAlignment
    private let placeholder: String
    private let onCommit: (() -> Void)?
    
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
    ///   - onCommit: Действие при подтверждении ввода.
    init(
        _ value: Binding<Double>,
        focusedField: FocusState<NumericEditField?>.Binding,
        focusID: NumericEditField,
        fractionDigits: Int,
        font: Font,
        textAlignment: TextAlignment,
        placeholder: String? = nil,
        onCommit: (() -> Void)? = nil
    ) {
        self._value = value
        self.focusedField = focusedField
        self.focusID = focusID
        self.font = font
        self.textAlignment = textAlignment
        self.onCommit = onCommit
        
        let inputState = DecimalInputState(
            maxFractionDigits: fractionDigits,
            usesGroupingSeparator: true
        )
        inputState.set(value.wrappedValue)
        inputState.commit()
        
        self._state = State(initialValue: inputState)
        self._textFieldText = State(initialValue: inputState.text)
        
        if let placeholder {
            self.placeholder = placeholder
        } else if fractionDigits == 0 {
            self.placeholder = "0"
        } else {
            let separator = inputState.separator
            let zeros = String(repeating: "0", count: fractionDigits)
            self.placeholder = "0\(separator)\(zeros)"
        }
    }
    
    // MARK: - Тело View
    
    var body: some View {
        TextField(placeholder, text: $textFieldText)
            .font(font)
            .focused(focusedField, equals: focusID)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(textAlignment)
            .focusedValue(
                \.keyboardClearAction,
                KeyboardClearAction(isEmpty: state.isEmpty, clear: clear)
            )
            .onAppear {
                hasUserChanges = false
                state.set(value)
                state.commit()
                textFieldText = state.text
            }
            .onChange(of: textFieldText) {
                updateInputFromText()
            }
            .onChange(of: value) { _, newValue in
                guard focusedField.wrappedValue != focusID else { return }
                hasUserChanges = false
                state.set(newValue)
                state.commit()
                textFieldText = state.text
            }
            .onChange(of: focusedField.wrappedValue) { oldID, newID in
                guard oldID == focusID, newID != focusID else { return }
                commit()
            }
            .onSubmit {
                commit()
            }
    }
    
    // MARK: - Приватные методы
    
    private func updateInputFromText() {
        guard textFieldText != state.text else { return }
        let previousInputText = state.replaceText(state.text)
        textFieldText = state.replaceText(textFieldText)
        guard state.text != previousInputText else { return }

        hasUserChanges = true
        let newValue = state.value
        if value != newValue {
            value = newValue
        }
    }

    private func clear() {
        hasUserChanges = false
        state.clear()
        textFieldText = state.text
        value = state.value
    }

    private func commit() {
        updateInputFromText()
        state.commit()
        textFieldText = state.text
        if hasUserChanges {
            hasUserChanges = false
            if value != state.value {
                value = state.value
            }
        }
        onCommit?()
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
