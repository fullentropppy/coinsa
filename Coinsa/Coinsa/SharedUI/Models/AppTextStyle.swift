//
//  AppTextStyle.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 22.11.2026.
//

import SwiftUI

/// Повторяющиеся роли вспомогательного текста без изменения его форматирования.
enum AppTextStyle: CaseIterable {
    // MARK: - Стили

    case secondaryFootnote
    case secondaryCaption
    case secondaryNumber

    // MARK: - Оформление

    /// Шрифт подписи с поддержкой системного размера текста.
    var font: Font {
        switch self {
        case .secondaryFootnote: .footnote
        case .secondaryCaption: .caption
        case .secondaryNumber: .footnote.monospacedDigit()
        }
    }

    /// Цвет вспомогательного текста.
    var color: Color { .secondary }
}
