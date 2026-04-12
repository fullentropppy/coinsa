//
//  NumericInputField.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.03.2026.
//

import SwiftUI

enum NumericEditField: Hashable {
    case amount
    case exchangeRate
    case exchangeAdjustmentPercentage
    case budget(String)
}

struct NumericInputField: View {
    // MARK: - Stored Properties
    
    @State private var text: String = ""
    
    @Binding var value: Double
    
    private let focusedField: FocusState<NumericEditField?>.Binding
    private let focusId: NumericEditField
    private let fractionDigits: Int
    
    // MARK: - Computed Properties
    
    private var parsingFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = fractionDigits
        formatter.usesGroupingSeparator = true
        return formatter
    }

    private var displayFormatter: NumberFormatter {
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
        
        let separator = displayFormatter.decimalSeparator ?? ","
        let zeros = String(repeating: "0", count: fractionDigits)
        
        return "0\(separator)\(zeros)"
    }
    
    // MARK: - Initialization
    
    init(
        _ value: Binding<Double>,
        focusedField: FocusState<NumericEditField?>.Binding,
        focusId: NumericEditField,
        fractionDigits: Int = 2,
    ) {
        self._value = value
        self.focusedField = focusedField
        self.focusId = focusId
        self.fractionDigits = fractionDigits
    }
    
    // MARK: - Body
    
    var body: some View {
        TextField(placeholder, text: $text)
            .focused(focusedField, equals: focusId)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .onAppear { syncFromValue() }
            .onChange(of: value) { _, _ in
                if focusedField.wrappedValue != focusId {
                    syncFromValue()
                }
            }
            .onChange(of: focusedField.wrappedValue) { _, newId in
                if newId != focusId {
                    commit()
                }
            }
            .onSubmit {
                commit()
            }
    }

    // MARK: - Actions
    
    private func syncFromValue() {
        text = value == 0 ? "" : displayFormatter.string(from: NSNumber(value: value)) ?? ""
    }

    private func commit() {
        let trimmed = text.trimmed
        
        guard !trimmed.isEmpty else {
            value = 0
            text = ""
            return
        }

        let groupingSeparator = parsingFormatter.groupingSeparator ?? ""
        let cleaned = trimmed.replacingOccurrences(of: groupingSeparator, with: "")
        let number = parsingFormatter.number(from: cleaned) ?? 0
        
        value = number.doubleValue
        text = displayFormatter.string(from: number) ?? cleaned
    }
}

// MARK: - Previews

private extension NumericInputField {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        NumericInputFieldPreview()
            .environment(\.locale, locale)
            .preferredColorScheme(colorScheme)
    }
}

private struct NumericInputFieldPreview: View {
    @State private var amount: Double = 1234.56
    @FocusState private var focusedField: NumericEditField?

    var body: some View {
        Form {
            LabeledContent(.expenseAmount) {
                NumericInputField(
                    $amount,
                    focusedField: $focusedField,
                    focusId: .amount
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
