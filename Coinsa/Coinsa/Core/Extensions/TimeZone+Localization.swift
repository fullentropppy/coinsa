//
//  TimeZone+Localization.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 17.11.2026.
//

import Foundation

/// Локализованное представление часового пояса.
extension TimeZone {
    /// Возвращает общее название без различия между стандартным и летним временем.
    /// - Parameter locale: Локаль отображения. По умолчанию текущая.
    /// - Returns: Системное локализованное название или идентификатор, если название недоступно.
    func localizedDisplayName(locale: Locale = .current) -> String {
        localizedName(for: .generic, locale: locale) ?? identifier
    }
}
