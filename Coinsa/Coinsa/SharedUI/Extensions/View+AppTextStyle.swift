//
//  View+AppTextStyle.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 22.11.2026.
//

import SwiftUI

// MARK: - Оформление текста

extension View {
    /// Применяет общий шрифт и цвет подписи, сохраняя способ подготовки текста.
    /// - Parameter style: Смысловая роль вспомогательного текста.
    func appTextStyle(_ style: AppTextStyle) -> some View {
        font(style.font)
            .foregroundStyle(style.color)
    }
}

// MARK: - Превью

#Preview {
    VStack(alignment: .leading, spacing: 20) {
        Text(.expenseComment)
            .appTextStyle(.secondaryFootnote)
        Text(.expenseDate)
            .appTextStyle(.secondaryCaption)
        Text(1234.56, format: .number)
            .appTextStyle(.secondaryNumber)
    }
    .padding()
}
