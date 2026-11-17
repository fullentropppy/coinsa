//
//  Double+Formatting.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.04.2026.
//

import Foundation

/// Форматирование чисел с плавающей запятой для отображения.
extension Double {
    /// Форматирует число с указанной точностью дробной части.
    /// Скрывает отрицательный знак у значений, округляющихся при отображении до нуля.
    /// - Parameters:
    ///   - fractionLength: Количество знаков после запятой. По умолчанию `2`.
    ///   - locale: Локаль отображения. По умолчанию текущая.
    /// - Returns: Строковое представление числа с заданным количеством дробных знаков.
    func numberFormat(fractionLength: Int = 2, locale: Locale = .current) -> String {
        self.formatted(
            .number
                .locale(locale)
                .precision(.fractionLength(fractionLength))
                .sign(strategy: sign == .minus ? .always(includingZero: false) : .automatic)
        )
    }

    /// Форматирует число с локализованным сокращением разряда и без лишних дробных нулей.
    /// Скрывает отрицательный знак у значений, округляющихся при отображении до нуля.
    /// - Parameters:
    ///   - fractionLength: Максимальное количество знаков после запятой. По умолчанию `2`.
    ///   - locale: Локаль отображения. По умолчанию текущая.
    /// - Returns: Компактная запись числа, например `1,25 млн` для русской локали.
    func compactNumberFormat(fractionLength: Int = 2, locale: Locale = .current) -> String {
        self.formatted(
            .number
                .locale(locale)
                .notation(.compactName)
                .precision(.fractionLength(0...max(0, fractionLength)))
                .sign(strategy: sign == .minus ? .always(includingZero: false) : .automatic)
        )
    }
    
    /// Форматирует число как процент с указанной точностью дробной части.
    /// Скрывает отрицательный знак у значений, округляющихся при отображении до нуля процентов.
    /// - Parameters:
    ///   - fractionLength: Количество знаков после запятой. По умолчанию `2`.
    ///   - locale: Локаль отображения. По умолчанию текущая.
    /// - Returns: Строковое представление числа в процентах.
    ///            Пример: `0.1234` → `"12.34%"`.
    func percentFormat(fractionLength: Int = 2, locale: Locale = .current) -> String {
        self.formatted(
            .percent
                .locale(locale)
                .precision(.fractionLength(fractionLength))
                .sign(strategy: sign == .minus ? .always(includingZero: false) : .automatic)
        )
    }
}
