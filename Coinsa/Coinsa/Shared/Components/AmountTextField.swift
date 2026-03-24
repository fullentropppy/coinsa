//
//  AmountTextField.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.03.2026.
//

// AmountTextField.swift
import SwiftUI

struct AmountTextField: View {
    @Binding var value: Double
    @State private var text: String = ""
    @FocusState private var isFocused: Bool
    
    private static let parsingFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    private static let displayFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    private var placeholder: String {
        let separator = Self.displayFormatter.decimalSeparator ?? ","
        return "0\(separator)00"
    }
    
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

    private func syncFromValue() {
        if value == 0 {
            text = ""
        } else {
            text = Self.displayFormatter.string(from: NSNumber(value: value)) ?? ""
        }
    }

    private func commit() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            value = 0
            text = ""
            return
        }

        let groupingSeparator = Self.parsingFormatter.groupingSeparator ?? ""
        let cleaned = trimmed.replacingOccurrences(of: groupingSeparator, with: "")
        let number = Self.parsingFormatter.number(from: cleaned) ?? 0
        value = number.doubleValue
        text = Self.displayFormatter.string(from: number) ?? cleaned
    }
}

// MARK: - Previews

#Preview("Light - RU") {
    Form {
        Section {
            LabeledContent {
                AmountTextField(value: .constant(1234))
            } label: {
                Text("expense.amount")
            }
        }
    }
    .environment(\.locale, PreviewLocale.ru.locale)
    .preferredColorScheme(.light)
}

#Preview("Dark - EN") {
    Form {
        Section {
            LabeledContent {
                AmountTextField(value: .constant(9876.5))
            } label: {
                Text("expense.amount")
            }
        }
    }
    .environment(\.locale, PreviewLocale.en.locale)
    .preferredColorScheme(.dark)
}

