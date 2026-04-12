//
//  AmountManager.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.04.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class AmountManager {
    // MARK: - Stored Properties
    
    private let converter: CurrencyConverter
    
    private(set) var baseAmount: Double
    private(set) var localAmount: Double
    
    // MARK: - Initialization
    
    init(converter: CurrencyConverter, baseAmount: Double = 0, localAmount: Double = 0) {
        self.converter = converter
        self.baseAmount = baseAmount
        self.localAmount = localAmount
    }
    
    // MARK: - Public Methods

    func amount(for inputCurrency: InputCurrency) -> Double {
        switch inputCurrency {
        case .base: baseAmount
        case .local: localAmount
        }
    }
    
    func updateAmount(_ newValue: Double, for inputCurrency: InputCurrency) {
        switch inputCurrency {
        case .base:
            baseAmount = newValue
            localAmount = converter.convertToLocal(fromBase: newValue)
        case .local:
            localAmount = newValue
            baseAmount = converter.convertToBase(fromLocal: newValue)
        }
    }
    
    func updateBaseAmount(_ newValue: Double) {
        baseAmount = newValue
        localAmount = converter.convertToLocal(fromBase: newValue)
    }
    
    func updateLocalAmount(_ newValue: Double) {
        localAmount = newValue
        baseAmount = converter.convertToBase(fromLocal: newValue)
    }
    
    func updateFromRateChange(inputCurrency: InputCurrency) {
        let currentAmount = amount(for: inputCurrency)
        updateAmount(currentAmount, for: inputCurrency)
    }
    
    func reset() {
        baseAmount = 0
        localAmount = 0
    }
}
