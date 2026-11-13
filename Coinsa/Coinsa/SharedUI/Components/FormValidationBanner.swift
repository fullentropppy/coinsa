//
//  FormValidationBanner.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.09.2026.
//

import SwiftUI

/// Сообщение валидации формы для верхней плашки.
struct FormValidationNotice: Identifiable {
    let id = UUID()
    let message: LocalizedStringResource
}

/// Верхняя плашка с ошибкой заполнения формы.
struct FormValidationBanner: View {
    // MARK: - Константы

    private enum Layout {
        /// Интервал между предупреждающей иконкой и текстом ошибки.
        static let contentSpacing: CGFloat = 6
        /// Внутренние отступы плашки ошибки формы.
        static let contentInset: CGFloat = 14
    }

    // MARK: - Свойства

    let message: LocalizedStringResource

    // MARK: - Тело View

    var body: some View {
        HStack(spacing: Layout.contentSpacing) {
            Image(systemName: "exclamationmark.circle")
                .foregroundStyle(.red)
                .imageScale(.small)

            Text(message)
                .font(.footnote)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, Layout.contentInset)
        .padding(.vertical, Layout.contentInset)
        .glassEffect(.regular.interactive(), in: Capsule())
    }
}

// MARK: - Превью

#Preview {
    FormValidationBanner(message: .validationAmountRequired)
}
