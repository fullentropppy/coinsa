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
    // MARK: - Свойства

    let message: LocalizedStringResource

    // MARK: - Тело View

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.circle")
                .foregroundStyle(.red)
                .imageScale(.small)

            Text(message)
                .font(.footnote)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .glassEffect(.regular.interactive(), in: Capsule())
    }
}

// MARK: - Превью

private extension FormValidationBanner {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        FormValidationBanner(message: .validationAmountRequired)
            .environment(\.locale, locale)
            .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    FormValidationBanner.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    FormValidationBanner.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
