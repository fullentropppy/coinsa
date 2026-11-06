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

    var activeSide: CurrencySide = .base
    
    // MARK: - Вычисляемые свойства

    var fromCurrency: Currency { converter.baseCurrency }
    var toCurrency: Currency { converter.quoteCurrency }
    var rate: Double { converter.rateQuoteToBase }
    var isRateLoading: Bool { converter.isRateLoading }

    var rateLoadingError: ExchangeRateLoadingError? {
        get { converter.rateLoadingError }
        set { converter.rateLoadingError = newValue }
    }

    /// Описание курса в виде «1 FROM = X TO».
    var unitRateDescription: String {
        guard rate > 0 else { return "—" }
        let value = converter.convertToQuote(fromBase: 1)
        return displayFormatter.string(from: NSNumber(value: value)) ?? "—"
    }

    // MARK: - Инициализация

    /// Создает ViewModel для конвертера валют.
    /// - Parameters:
    ///   - from: Исходная валюта. По умолчанию — доллар США.
    ///   - to: Целевая валюта. По умолчанию — российский рубль.
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

    /// Числовое значение для указанной стороны с учетом введенного текста и курса.
    /// - Parameter side: Сторона валютной пары.
    /// - Returns: Сумма в валюте этой стороны.
    func amount(for side: CurrencySide) -> Double {
        let parsed = parsedNumber(from: inputText)

        switch side {
        case .base:
            return activeSide == .base
                ? parsed
                : converter.convertToBase(fromQuote: parsed)
        case .quote:
            return activeSide == .quote
                ? parsed
                : converter.convertToQuote(fromBase: parsed)
        }
    }

    /// Текст для отображения в поле указанной стороны.
    /// Возвращает пустую строку, если нужно показать плейсхолдер «0».
    /// - Parameter side: Сторона валютной пары.
    func displayText(for side: CurrencySide) -> String {
        if side == activeSide {
            return inputText
        }
        let amount = amount(for: side)
        guard amount > 0 else { return "" }
        return displayFormatter.string(from: NSNumber(value: amount)) ?? ""
    }

    func isActive(_ side: CurrencySide) -> Bool {
        activeSide == side
    }

    // MARK: - Ввод

    func setActiveSide(_ side: CurrencySide) {
        guard side != activeSide else { return }
        let currentAmount = amount(for: side)
        activeSide = side
        inputText = currentAmount > 0 ? rawString(from: currentAmount) : ""
    }

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
        let oldBaseAmount = amount(for: .base)
        let oldQuoteAmount = amount(for: .quote)

        // Мгновенно меняем валюты местами и инвертируем курс.
        converter.updateBaseCurrency(oldQuote)
        converter.updateQuoteCurrency(oldBase)
        if oldRate > 0 {
            converter.updateRate(1 / oldRate)
        }

        // Сохраняем визуальную позицию фокуса: сумма «переезжает» в другую позицию.
        if activeSide == .base {
            inputText = oldQuoteAmount > 0 ? rawString(from: oldQuoteAmount) : ""
        } else {
            inputText = oldBaseAmount > 0 ? rawString(from: oldBaseAmount) : ""
        }
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

    /// Форматтер для ввода (без группировки, для парсинга и построения raw-строки).
    private let inputFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        return formatter
    }()

    /// Форматтер для отображения суммы (с группировкой, фиксированные 2 знака).
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
