//
//  ExchangeRateProvider.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 07.04.2026.
//

import Foundation

final class ExchangeRateProvider {
    // MARK: - Public Methods
    
    private let service: ExchangeRateService
    
    // MARK: - Initialization
    
    init(service: ExchangeRateService) {
        self.service = service
    }
    
    // MARK: - Public Methods
    
    func getRate(from: Currency, to: Currency) async throws -> Double {
        try await AsyncTimeout.run(seconds: 5) {
            try await self.service.fetchRate(from: from, to: to)
        }
    }
}

// MARK: - Errors

struct ExchangeRateLoadingError: LocalizedError {
    var errorDescription: String? {
        String(localized: .exchangeRateLoadingException)
    }
}
