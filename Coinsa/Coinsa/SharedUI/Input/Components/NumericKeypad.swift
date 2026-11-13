//
//  NumericKeypad.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.11.2026.
//

import SwiftUI

/// Кастомная цифровая клавиатура для ввода числовых значений.
struct NumericKeypad: View {
    // MARK: - Константы

    private enum Layout {
        /// Минимальная высота клавиши цифровой клавиатуры.
        static let keyMinHeight: CGFloat = 47
        /// Интервал между клавишами и рядами клавиатуры.
        static let keySpacing: CGFloat = 12
        /// Внешние отступы цифровой клавиатуры.
        static let contentInset: CGFloat = 18
        /// Длительность удержания удаления для очистки всего значения.
        static let clearPressDuration: TimeInterval = 0.5
    }

    // MARK: - Свойства

    let onDigit: (String) -> Void
    let onDelete: () -> Void
    let onClear: () -> Void

    // MARK: - Тело View

    var body: some View {
        VStack(spacing: Layout.keySpacing) {
            row(["1", "2", "3"])
            row(["4", "5", "6"])
            row(["7", "8", "9"])
            HStack(spacing: Layout.keySpacing) {
                digitKey(Locale.current.decimalSeparator ?? ",")
                digitKey("0")
                deleteKey
            }
        }
        .padding(.horizontal, Layout.contentInset)
        .padding(.vertical, Layout.contentInset)
    }

    // MARK: - Компоненты

    private func row(_ digits: [String]) -> some View {
        HStack(spacing: Layout.keySpacing) {
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
                .frame(maxWidth: .infinity, minHeight: Layout.keyMinHeight)
        }
        .buttonStyle(.glass)
    }

    private var deleteKey: some View {
        Button {
            onDelete()
        } label: {
            Image(systemName: "delete.left")
                .font(.title2)
                .frame(maxWidth: .infinity, minHeight: Layout.keyMinHeight)
        }
        .buttonStyle(.glass)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: Layout.clearPressDuration)
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
