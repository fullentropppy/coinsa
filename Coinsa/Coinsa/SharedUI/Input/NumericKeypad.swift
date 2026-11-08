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

    private let keyMinHeight: CGFloat = 56
    private let spacing: CGFloat = 12
    
    let onDigit: (String) -> Void
    let onDelete: () -> Void
    let onClear: () -> Void

    // MARK: - Тело View

    var body: some View {
        VStack(spacing: spacing) {
            row(["1", "2", "3"])
            row(["4", "5", "6"])
            row(["7", "8", "9"])
            HStack(spacing: spacing) {
                digitKey(Locale.current.decimalSeparator ?? ",")
                digitKey("0")
                deleteKey
            }
        }
        .padding(.horizontal, 17)
        .padding(.vertical, 17)
    }

    // MARK: - Компоненты

    private func row(_ digits: [String]) -> some View {
        HStack(spacing: spacing) {
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
                .frame(maxWidth: .infinity, minHeight: keyMinHeight)
        }
        .buttonStyle(.glass)
    }

    private var deleteKey: some View {
        Button {
            onDelete()
        } label: {
            Image(systemName: "delete.left")
                .font(.title2)
                .frame(maxWidth: .infinity, minHeight: keyMinHeight)
        }
        .buttonStyle(.glass)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.4)
                .onEnded { _ in onClear() }
        )
    }
}

// MARK: - Превью

#Preview {
    NumericKeypad(
        onDigit: { _ in },
        onDelete: {},
        onClear: {}
    )
}
