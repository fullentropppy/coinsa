//
//  NumericKeypad.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.11.2026.
//

import SwiftUI

/// Кастомная цифровая клавиатура для ввода числовых значений.
struct NumericKeypad: View {
    // MARK: - Свойства

    private var decimalSeparator: String {
        Locale.current.decimalSeparator ?? ","
    }
    
    let onDigit: (String) -> Void
    let onDelete: () -> Void

    // MARK: - Тело View

    var body: some View {
        VStack(spacing: 12) {
            row(["1", "2", "3"])
            row(["4", "5", "6"])
            row(["7", "8", "9"])
            HStack(spacing: 12) {
                digitKey(decimalSeparator)
                digitKey("0")
                deleteKey
            }
        }
        .padding(.horizontal, 17)
        .padding(.vertical, 17)
    }

    // MARK: - Компоненты

    private func row(_ digits: [String]) -> some View {
        HStack(spacing: 12) {
            ForEach(digits, id: \.self) { digit in
                digitKey(digit)
            }
        }
    }

    private func digitKey(_ label: String) -> some View {
        Button {
            onDigit(label)
        } label: {
            Text(label)
                .font(.title2)
                .frame(maxWidth: .infinity, maxHeight: 38)
        }
        .buttonStyle(.glass)
    }

    private var deleteKey: some View {
        Button {
            onDelete()
        } label: {
            Image(systemName: "delete.left")
                .font(.title2)
                .frame(maxWidth: .infinity, minHeight: 38)
        }
        .buttonStyle(.glass)
    }
}

// MARK: - Превью

#Preview {
    NumericKeypad(
        onDigit: { _ in },
        onDelete: {}
    )
}
