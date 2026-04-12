//
//  CurrencyConverter.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.04.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class CurrencyConverter {
    // MARK: - Stored Properties
    
    private let exchangeRateManager: ExchangeRateManager
    private(set) var baseCurrency: Currency
    private(set) var localCurrency: Currency
    private(set) var rateLocalToBase: Double
    private(set) var exchangeAdjustmentPercentage: Double
    
    // MARK: - Computed Properties
    
    var isRateLoading: Bool {
        exchangeRateManager.isRateLoading
    }
    
    var rateLoadingError: ExchangeRateLoadingError? {
        get { exchangeRateManager.rateLoadingError }
        set { exchangeRateManager.rateLoadingError = newValue }
    }
    
    var isHomeLocation: Bool {
        baseCurrency == localCurrency
    }
    
    // MARK: - Initialization
    
    init(
        exchangeRateProvider: ExchangeRateProvider,
        baseCurrency: Currency,
        localCurrency: Currency,
        rateLocalToBase: Double = 1,
        exchangeAdjustmentPercentage: Double = 0
    ) {
        self.exchangeRateManager = ExchangeRateManager(provider: exchangeRateProvider)
        self.baseCurrency = baseCurrency
        self.localCurrency = localCurrency
        self.rateLocalToBase = rateLocalToBase
        self.exchangeAdjustmentPercentage = max(0, exchangeAdjustmentPercentage)
    }
    
    // MARK: - Public Methods
    
    func updateLocalCurrency(_ newCurrency: Currency) {
        let oldCurrency = localCurrency
        localCurrency = newCurrency
        
        if isHomeLocation {
            exchangeRateManager.cancelRefresh()
            rateLocalToBase = 1
        } else if localCurrency != oldCurrency {
            requestRateRefresh()
        }
    }
    
    func updateBaseCurrency(_ newCurrency: Currency) {
        let oldBase = baseCurrency
        baseCurrency = newCurrency
        
        if isHomeLocation {
            exchangeRateManager.cancelRefresh()
            rateLocalToBase = 1
        } else if baseCurrency != oldBase {
            requestRateRefresh()
        }
    }
    
    func updateRate(_ newRate: Double) {
        rateLocalToBase = newRate
    }

    func updateExchangeAdjustmentPercentage(_ newPercentage: Double) {
        exchangeAdjustmentPercentage = max(0, newPercentage)
    }
    
    func requestRateRefresh(completion: ((Double) -> Void)? = nil) {
        exchangeRateManager.requestRefresh(
            from: localCurrency,
            to: baseCurrency
        ) { [weak self] rate in
            self?.rateLocalToBase = rate
            completion?(rate)
        }
    }
    
    func convertToBase(fromLocal amount: Double) -> Double {
        let effectiveRate = effectiveRateLocalToBase
        guard effectiveRate > 0 else { return 0 }
        return (amount * effectiveRate).rounded(to: 2)
    }
    
    func convertToLocal(fromBase amount: Double) -> Double {
        let effectiveRate = effectiveRateLocalToBase
        guard effectiveRate > 0 else { return 0 }
        return (amount / effectiveRate).rounded(to: 2)
    }
    
    func convertAmount(_ amount: Double, from source: InputCurrency, to target: InputCurrency) -> Double {
        switch (source, target) {
        case (.base, .local): convertToLocal(fromBase: amount)
        case (.local, .base): convertToBase(fromLocal: amount)
        default: amount
        }
    }

    // MARK: - Private Methods

    private var effectiveRateLocalToBase: Double {
        rateLocalToBase * (1 + (exchangeAdjustmentPercentage / 100))
    }
}
