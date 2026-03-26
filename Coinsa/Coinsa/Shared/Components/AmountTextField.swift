//
//  AmountTextField.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.03.2026.
//

import SwiftUI

struct AmountTextField: View {
    // MARK: - Stored Properties
    
    @Binding var value: Double
    @State private var text: String = ""
    @FocusState private var isFocused: Bool
    
    // MARK: - Computed Properties
    
    private let parsingFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    private let displayFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    private var placeholder: String {
        let separator = displayFormatter.decimalSeparator ?? ","
        return "0\(separator)00"
    }
    
    // MARK: - Body
    
    var body: some View {
        TextField(placeholder, text: $text)
            .focused($isFocused)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .onAppear {
                syncFromValue()
            }
            .onChange(of: value) { _, _ in
                guard !isFocused else { return }
                syncFromValue()
            }
            .onChange(of: isFocused) { _, focused in
                if !focused {
                    commit()
                }
            }
            .onSubmit {
                commit()
            }
    }

    // MARK: - Actions
    
    private func syncFromValue() {
        if value == 0 {
            text = ""
        } else {
            text = displayFormatter.string(from: NSNumber(value: value)) ?? ""
        }
    }

    private func commit() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
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

private extension AmountTextField {
    static func preview(
        locale: Locale,
        colorScheme: ColorScheme
    ) -> some View {
        Form {
            LabeledContent("") {
                AmountTextField(value: .constant(1234.56))
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    AmountTextField.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    AmountTextField.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}


