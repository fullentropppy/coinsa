//
//  DecimalInputState.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.11.2026.
//

import Foundation
import Observation

/// Состояние числового ввода.
@Observable
final class DecimalInputState {
    // MARK: - Хранимые свойства

    private let locale: Locale
    private let formatter: NumberFormatter

    private(set) var text: String = ""
    
    let maxFractionDigits: Int
    let usesGroupingSeparator: Bool
    
    // MARK: - Вычисляемые свойства

    var separator: String {
        locale.decimalSeparator ?? ","
    }

    var isEmpty: Bool {
        text.isEmpty
    }

    var value: Double {
        guard !text.isEmpty else { return 0 }

        var cleaned = text
        if usesGroupingSeparator {
            let grouping = formatter.groupingSeparator ?? ""
            cleaned = cleaned.replacingOccurrences(of: grouping, with: "")
        }

        let normalized = cleaned.replacingOccurrences(of: separator, with: ".")
        guard !normalized.isEmpty, normalized != "." else { return 0 }
        return Double(normalized) ?? 0
    }

    // MARK: - Инициализация

    /// Создает состояние числового ввода.
    /// - Parameters:
    ///   - maxFractionDigits: Максимальное количество знаков после запятой. По умолчанию `2`.
    ///   - usesGroupingSeparator: Флаг группировки разрядов при форматировании. По умолчанию `false`.
    ///   - locale: Локаль для определения десятичного разделителя и группировки. По умолчанию `.current`.
    init(
        maxFractionDigits: Int = 2,
        usesGroupingSeparator: Bool = false,
        locale: Locale = .current
    ) {
        self.maxFractionDigits = maxFractionDigits
        self.usesGroupingSeparator = usesGroupingSeparator
        self.locale = locale

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = maxFractionDigits
        formatter.maximumFractionDigits = maxFractionDigits
        formatter.usesGroupingSeparator = usesGroupingSeparator
        formatter.locale = locale
        self.formatter = formatter
    }
    
    // MARK: - Кастомная клавиатура

    func append(_ character: String) {
        guard character.count == 1, let ch = character.first else { return }

        if String(ch) == separator {
            appendSeparator()
            return
        }

        guard ch.isASCII, ch.isNumber else { return }
        appendDigit(ch)
    }

    func deleteLast() {
        guard !text.isEmpty else { return }
        text.removeLast()
    }

    func clear() {
        text = ""
    }

    // MARK: - Программные изменения

    func set(_ newValue: Double) {
        text = newValue > 0 ? format(newValue) : ""
    }

    func replaceText(_ newText: String) -> String {
        let sanitized = sanitize(newText)
        text = sanitized
        return sanitized
    }

    func commit() {
        text = value > 0 ? format(value) : ""
    }

    // MARK: - Приватные методы

    private func appendSeparator() {
        guard !text.contains(separator) else { return }
        if text.isEmpty { text = "0" }
        text += separator
    }

    private func appendDigit(_ digit: Character) {
        if text == "0" { text = "" }

        if let range = text.range(of: separator) {
            let fractionCount = text.distance(from: range.upperBound, to: text.endIndex)
            guard fractionCount < maxFractionDigits else { return }
        }

        text.append(digit)
    }

    private func format(_ value: Double) -> String {
        formatter.string(from: NSNumber(value: value)) ?? ""
    }

    private func sanitize(_ input: String) -> String {
        var result = ""
        var separatorUsed = false

        for ch in input {
            if ch.isASCII, ch.isNumber {
                result.append(ch)
            } else if String(ch) == separator, !separatorUsed {
                result.append(ch)
                separatorUsed = true
            }
        }

        if let range = result.range(of: separator) {
            let fraction = result[range.upperBound...]
            if fraction.count > maxFractionDigits {
                result = String(result.prefix(result.count - (fraction.count - maxFractionDigits)))
            }
        }

        return result
    }
}
