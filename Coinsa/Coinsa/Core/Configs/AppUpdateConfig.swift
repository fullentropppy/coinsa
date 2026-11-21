//
//  AppUpdateConfig.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 21.11.2026.
//

import Foundation

/// Параметры получения сведений об обновлении приложения.
enum AppUpdateConfig {
    /// Публичный JSON канала TestFlight без ссылки-приглашения.
    static let endpoint = URL(string: "https://coinsa-api.coinsa.workers.dev/ios/testflight.json")!
    /// Минимальный интервал между проверками в секундах.
    static let checkInterval: TimeInterval = 6 * 60 * 60
    /// Максимальное время ожидания ответа API в секундах.
    static let requestTimeout: TimeInterval = 15
}
