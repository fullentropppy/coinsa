//
//  AppSettings.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftData

@Model
final class AppSettings {
    // MARK: - Свойства

    var baseCurrencyCode: String

    // MARK: - Инициализация

    init(baseCurrencyCode: String) {
        self.baseCurrencyCode = baseCurrencyCode
    }
}
