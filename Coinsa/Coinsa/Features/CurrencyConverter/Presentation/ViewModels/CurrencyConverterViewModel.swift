//
//  CurrencyConverterViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 05.11.2026.
//

import Foundation
import Observation

struct CurrencyConversionRecord: Codable, Identifiable, Equatable {
    let id: UUID
    let date: Date
    let sourceCurrency: Currency
    let destinationCurrency: Currency
    let sourceAmount: Double
    let destinationAmount: Double
    let rate: Double
}

@MainActor
@Observable
final class CurrencyConverterViewModel {
    private(set) var sourceCurrency: Currency
    private(set) var destinationCurrency: Currency
    private(set) var sourceAmount: Double
    private(set) var destinationAmount: Double
    private(set) var history: [CurrencyConversionRecord]

    private var converter: CurrencyConverter
    private var amountManager: AmountManager
    private var needsInitialRateRefresh: Bool
    private let storage = CurrencyConverterStorage()

    var rate: Double { converter.rateQuoteToBase }
    var isRateLoading: Bool { converter.isRateLoading }

    var rateLoadingError: ExchangeRateLoadingError? {
        get { converter.rateLoadingError }
        set { converter.rateLoadingError = newValue }
    }

    var rateDescription: LocalizedStringResource? {
        // TODO: Изменить ключ
        .todayExchangeRate(
            currencyCode1: sourceCurrency.code,
            rate1To2: rate.numberFormat(fractionLength: 4),
            currencyCode2: destinationCurrency.code
        )
    }

    init(baseCurrency: Currency) {
        let storage = CurrencyConverterStorage()
        let snapshot = storage.snapshot
        let sourceCurrency = snapshot?.sourceCurrency ?? baseCurrency
        let destinationCurrency = snapshot?.destinationCurrency
            ?? (baseCurrency == .usd ? .eur : .usd)
        let rate = snapshot?.rate ?? 1
        let sourceAmount = snapshot?.sourceAmount ?? 0

        let converter = CurrencyConverter(
            exchangeRateProvider: ExchangeRateProvider(service: HexarateService()),
            baseCurrency: destinationCurrency,
            quoteCurrency: sourceCurrency,
            rateQuoteToBase: rate,
            exchangeAdjustment: 0
        )
        let amountManager = AmountManager(
            converter: converter,
            quoteAmount: sourceAmount
        )
        amountManager.updateQuoteAmount(sourceAmount, useExchangeAdjustment: false)

        self.sourceCurrency = sourceCurrency
        self.destinationCurrency = destinationCurrency
        self.sourceAmount = sourceAmount
        self.destinationAmount = snapshot?.destinationAmount ?? amountManager.baseAmount
        self.history = storage.history
        self.converter = converter
        self.amountManager = amountManager
        self.needsInitialRateRefresh = snapshot == nil
    }

    func loadInitialRateIfNeeded() {
        guard needsInitialRateRefresh else { return }
        needsInitialRateRefresh = false
        refreshRate()
    }

    func updateSourceAmount(_ amount: Double) {
        sourceAmount = amount
        amountManager.updateQuoteAmount(amount, useExchangeAdjustment: false)
        destinationAmount = amountManager.baseAmount
        saveSnapshot()
    }

    func updateSourceCurrency(_ currency: Currency) {
        guard currency != sourceCurrency else { return }
        if currency == destinationCurrency {
            swapCurrencies()
            return
        }

        sourceCurrency = currency
        rebuildConverter(rate: 1)
        refreshRate(addToHistory: true)
    }

    func updateDestinationCurrency(_ currency: Currency) {
        guard currency != destinationCurrency else { return }
        if currency == sourceCurrency {
            swapCurrencies()
            return
        }

        destinationCurrency = currency
        rebuildConverter(rate: 1)
        refreshRate(addToHistory: true)
    }

    func swapCurrencies() {
        let oldSource = sourceCurrency
        sourceCurrency = destinationCurrency
        destinationCurrency = oldSource

        let invertedRate = rate > 0 ? 1 / rate : 0
        rebuildConverter(rate: invertedRate)
        addCurrentConversionToHistory()
    }

    func refreshRate() {
        refreshRate(addToHistory: true, onlyIfRateChanged: true)
    }

    func addCurrentConversionToHistory() {
        guard sourceAmount > 0, rate > 0 else { return }

        let record = CurrencyConversionRecord(
            id: UUID(),
            date: Date(),
            sourceCurrency: sourceCurrency,
            destinationCurrency: destinationCurrency,
            sourceAmount: sourceAmount,
            destinationAmount: destinationAmount,
            rate: rate
        )
        history.insert(record, at: 0)
        history = Array(history.prefix(20))
        storage.history = history
    }

    func deleteHistoryRecord(_ record: CurrencyConversionRecord) {
        history.removeAll { $0.id == record.id }
        storage.history = history
    }

    func clearHistory() {
        history.removeAll()
        storage.history = history
    }

    private func refreshRate(
        addToHistory: Bool = false,
        onlyIfRateChanged: Bool = false
    ) {
        let requestedConverter = converter
        let previousRate = rate

        requestedConverter.requestRateRefresh { [weak self, weak requestedConverter] newRate in
            guard let self, let requestedConverter, converter === requestedConverter else { return }

            recalculate()
            saveSnapshot()

            let rateChanged = abs(newRate - previousRate) > Double.ulpOfOne
            if addToHistory && (!onlyIfRateChanged || rateChanged) {
                addCurrentConversionToHistory()
            }
        }
    }

    private func rebuildConverter(rate: Double) {
        let converter = CurrencyConverter(
            exchangeRateProvider: ExchangeRateProvider(service: HexarateService()),
            baseCurrency: destinationCurrency,
            quoteCurrency: sourceCurrency,
            rateQuoteToBase: rate,
            exchangeAdjustment: 0
        )
        self.converter = converter
        self.amountManager = AmountManager(
            converter: converter,
            quoteAmount: sourceAmount
        )
        recalculate()
        saveSnapshot()
    }

    private func recalculate() {
        amountManager.updateQuoteAmount(sourceAmount, useExchangeAdjustment: false)
        destinationAmount = amountManager.baseAmount
    }

    private func saveSnapshot() {
        storage.snapshot = CurrencyConverterSnapshot(
            sourceCurrency: sourceCurrency,
            destinationCurrency: destinationCurrency,
            sourceAmount: sourceAmount,
            destinationAmount: destinationAmount,
            rate: rate
        )
    }
}

private struct CurrencyConverterSnapshot: Codable {
    let sourceCurrency: Currency
    let destinationCurrency: Currency
    let sourceAmount: Double
    let destinationAmount: Double
    let rate: Double
}

private final class CurrencyConverterStorage {
    private let defaults = UserDefaults.standard

    var snapshot: CurrencyConverterSnapshot? {
        get { decode(CurrencyConverterSnapshot.self, forKey: Key.snapshot) }
        set { encode(newValue, forKey: Key.snapshot) }
    }

    var history: [CurrencyConversionRecord] {
        get { decode([CurrencyConversionRecord].self, forKey: Key.history) ?? [] }
        set { encode(newValue, forKey: Key.history) }
    }

    private func decode<Value: Decodable>(_ type: Value.Type, forKey key: String) -> Value? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private func encode<Value: Encodable>(_ value: Value?, forKey key: String) {
        guard let value, let data = try? JSONEncoder().encode(value) else {
            defaults.removeObject(forKey: key)
            return
        }
        defaults.set(data, forKey: key)
    }

    private enum Key {
        static let snapshot = "currencyConverter.snapshot"
        static let history = "currencyConverter.history"
    }
}
