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
final class CurrencyCurrencyConverterViewModel {
    // MARK: - Зависимости

    private let converter: CurrencyConverter

    // MARK: - Состояние UI

    private var hasLoadedInitialRate = false
    private(set) var inputText: String = ""

    // MARK: - Вычисляемые свойства

    var fromCurrency: Currency { converter.baseCurrency }
    var toCurrency: Currency { converter.quoteCurrency }
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

    // MARK: - Суммы

    /// Числовое значение для указанной стороны.
    /// Ввод всегда идёт в базовую валюту (`From`), вторая сторона вычисляется из курса.
    func amount(for side: CurrencySide) -> Double {
        let parsed = parsedNumber(from: inputText)
        switch side {
        case .base:
            return parsed
        case .quote:
            return converter.convertToQuote(fromBase: parsed)
        }
    }

    /// Текст для отображения в поле указанной стороны.
    func displayText(for side: CurrencySide) -> String {
        switch side {
        case .base:
            return inputText
        case .quote:
            let amount = amount(for: .quote)
            guard amount > 0 else { return "" }
            return displayFormatter.string(from: NSNumber(value: amount)) ?? ""
        }
    }

    // MARK: - Ввод

    func append(_ character: String) {
        let separator = inputFormatter.decimalSeparator ?? ","
        guard character.allSatisfy({ $0.isNumber || String($0) == separator }) else { return }
        if character == separator && inputText.contains(separator) { return }
        inputText += character
    }

    func deleteLast() {
        guard !inputText.isEmpty else { return }
        inputText.removeLast()
    }

    /// Полностью очищает введённую сумму.
    func clearInput() {
        inputText = ""
    }

    // MARK: - Валюты

    func updateFromCurrency(_ currency: Currency) {
        converter.updateBaseCurrency(currency)
    }

    func updateToCurrency(_ currency: Currency) {
        converter.updateQuoteCurrency(currency)
    }

    func swapCurrencies() {
        let oldBase = fromCurrency
        let oldQuote = toCurrency
        let oldRate = rate
        let oldQuoteAmount = amount(for: .quote)

        // Меняем валюты местами и инвертируем курс.
        converter.updateBaseCurrency(oldQuote)
        converter.updateQuoteCurrency(oldBase)
        if oldRate > 0 {
            converter.updateRate(1 / oldRate)
        }

        // Ввод всегда во `From`, поэтому «перевозим» ранее вычисленную
        // сумму из `To` в `From`, чтобы пользователь видел те же числа.
        inputText = oldQuoteAmount > 0 ? rawString(from: oldQuoteAmount) : ""
    }

    // MARK: - Курс обмена

    func loadInitialRateIfNeeded() {
        guard !hasLoadedInitialRate else { return }
        hasLoadedInitialRate = true
        guard fromCurrency != toCurrency else { return }
        requestRateRefresh()
    }

    func requestRateRefresh() {
        converter.requestRateRefresh()
    }

    // MARK: - Форматтеры

    private let inputFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        return formatter
    }()

    private let displayFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    // MARK: - Приватные методы

    private func parsedNumber(from text: String) -> Double {
        guard !text.isEmpty else { return 0 }
        let separator = inputFormatter.decimalSeparator ?? ","
        var normalized = text.replacingOccurrences(of: separator, with: ".")
        if normalized.hasSuffix(".") {
            normalized = String(normalized.dropLast())
        }
        return Double(normalized) ?? 0
    }

    private func rawString(from value: Double) -> String {
        inputFormatter.string(from: NSNumber(value: value)) ?? ""
    }
}
