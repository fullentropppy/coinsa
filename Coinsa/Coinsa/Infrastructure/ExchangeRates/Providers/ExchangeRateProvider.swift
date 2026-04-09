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
            try await self.service.fetchRate(from: from, to: to).rounded(to: 4)
        }
    }
}

// MARK: - Errors

struct ExchangeRateLoadingError: LocalizedError {
    // MARK: - Stored Properties
    
    let details: String?
    
    // MARK: - Computed Properties
    
    var errorDescription: String? {
        if let details, !details.isBlank {
            details
        } else {
            String(localized: .exchangeRateLoadingException)
        }
    }
    
    // MARK: - Initialization
    
    init(details: String? = nil) {
        self.details = details
    }
}
