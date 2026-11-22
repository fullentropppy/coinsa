//
//  PreviewExchangeRateService.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 18.11.2026.
//

import Foundation

/// Локальные курсы превью на основе демоданных без обращения к сети.
struct PreviewExchangeRateService: ExchangeRateService {
    // MARK: - Методы

    /// Возвращает синтетический курс; для неподдерживаемой пары сообщает об ошибке загрузки.
    /// - Parameters:
    ///   - from: Исходная валюта.
    ///   - to: Целевая валюта.
    func fetchRate(from: Currency, to: Currency) async throws -> Double {
        try Task.checkCancellation()
        guard from != to else { return 1 }
        guard let fromRate = PreviewExchangeRates.availableRateToHome(for: from),
              let toRate = PreviewExchangeRates.availableRateToHome(for: to) else {
            throw ExchangeRateLoadingError()
        }
        return fromRate / toRate
    }
}
