//
//  ExchangeRateProvider.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 07.04.2026.
//

import Foundation

final class ExchangeRateProvider {
    // MARK: - Свойства
    
    private let service: ExchangeRateService
    
    // MARK: - Инициализация
    
    init(service: ExchangeRateService) {
        self.service = service
    }
    
    // MARK: - Публичные методы
    
    func getRate(from: Currency, to: Currency) async throws -> Double {
        try await AsyncTimeout.run(seconds: 5) {
            try await self.service.fetchRate(from: from, to: to)
        }
    }
}

// MARK: - Ошибки

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
