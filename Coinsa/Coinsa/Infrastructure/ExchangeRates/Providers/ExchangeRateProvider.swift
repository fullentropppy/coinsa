//
//  ExchangeRateProvider.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 07.04.2026.
//

import Foundation

/// Провайдер курсов обмена.
final class ExchangeRateProvider {
    // MARK: - Свойства
    
    private let service: ExchangeRateService
    
    // MARK: - Инициализация
    
    /// Создает провайдер с указанным сервисом.
    /// - Parameter service: Сервис для получения курсов.
    init(service: ExchangeRateService) {
        self.service = service
    }
    
    // MARK: - Публичные методы
    
    /// Получает курс обмена с таймаутом 10 секунд.
    /// - Parameters:
    ///   - from: Исходная валюта.
    ///   - to: Целевая валюта.
    /// - Returns: Курс обмена (сколько единиц `to` за 1 единицу `from`).
    /// - Throws: Ошибки сети, декодирования или невалидного URL.
    func getRate(from: Currency, to: Currency) async throws -> Double {
        try await AsyncTimeout.run(seconds: 10) {
            try await self.service.fetchRate(from: from, to: to)
        }
    }
}

// MARK: - Ошибки

/// Ошибка загрузки курса обмена.
struct ExchangeRateLoadingError: LocalizedError {
    // MARK: - Свойства
    
    let details: String?
    
    var errorDescription: String? {
        if let details, !details.isBlank {
            details
        } else {
            String(localized: .exchangeRateLoadingException)
        }
    }
    
    // MARK: - Инициализация
    
    init(details: String? = nil) {
        self.details = details
    }
}
