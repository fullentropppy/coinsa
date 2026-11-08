//
//  CurrencyConverterViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.11.2026.
//

import Foundation
import Observation

/// ViewModel для экрана конвертера валют.
@MainActor
@Observable
final class CurrencyConverterViewModel {
    // MARK: - Зависимости

    private let converter: CurrencyConverter

    // MARK: - Состояние UI

    private var hasLoadedInitialRate = false
    
    let input = DecimalInputState(maxFractionDigits: 2)

    // MARK: - Вычисляемые свойства

    var baseCurrency: Currency { converter.baseCurrency }
    var quoteCurrency: Currency { converter.quoteCurrency }
    var rate: Double { converter.rateQuoteToBase }
    var isRateLoading: Bool { converter.isRateLoading }

    var rateLoadingError: ExchangeRateLoadingError? {
        get { converter.rateLoadingError }
        set { converter.rateLoadingError = newValue }
    }

    var unitRate: Double {
        guard rate > 0 else { return 0 }
        return converter.convertToQuote(fromBase: 1)
    }

    // MARK: - Инициализация

    init(from: Currency = .usd, to: Currency = .rub) {
        let provider = ExchangeRateProvider(service: HexarateService())
        let initialRate: Double = from == to ? 1 : 0

        self.converter = CurrencyConverter(
            exchangeRateProvider: provider,
            baseCurrency: from,
            quoteCurrency: to,
            rateQuoteToBase: initialRate
        )
    }

    // MARK: - Восстановление состояния

    func restorePersistedState(amount: Double, base: Currency, quote: Currency) {
        converter.setCurrencies(base: base, quote: quote)
        if amount > 0 {
            input.set(amount)
        }
    }
    
    // MARK: - Суммы

    func amount(for side: CurrencyPairSide) -> Double {
        switch side {
        case .base:
            input.value
        case .quote:
            converter.convertToQuote(fromBase: input.value)
        }
    }

    func displayText(for side: CurrencyPairSide) -> String {
        switch side {
        case .base:
            return input.formattedText
        case .quote:
            let amount = amount(for: .quote)
            guard amount > 0 else { return "" }
            return amount.numberFormat(fractionLength: 2)
        }
    }

    // MARK: - Валюты

    func updateBaseCurrency(_ currency: Currency) {
        converter.updateBaseCurrency(currency)
    }

    func updateQuoteCurrency(_ currency: Currency) {
        converter.updateQuoteCurrency(currency)
    }

    func swapCurrencies() {
        let oldBase = baseCurrency
        let oldQuote = quoteCurrency
        let oldRate = rate
        let oldQuoteAmount = amount(for: .quote)

        converter.updateBaseCurrency(oldQuote)
        converter.updateQuoteCurrency(oldBase)
        if oldRate > 0 {
            converter.updateRate(1 / oldRate)
        }

        input.set(oldQuoteAmount)
    }

    // MARK: - Курс обмена

    func loadInitialRateIfNeeded() {
        guard !hasLoadedInitialRate else { return }
        hasLoadedInitialRate = true
        guard baseCurrency != quoteCurrency else { return }
        requestRateRefresh()
    }

    func requestRateRefresh() {
        converter.requestRateRefresh()
    }
}
