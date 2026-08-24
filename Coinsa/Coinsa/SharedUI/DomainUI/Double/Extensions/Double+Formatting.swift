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
    /// - Parameter fractionLength: Количество знаков после запятой. По умолчанию `2`.
    /// - Returns: Строковое представление числа с заданным количеством дробных знаков.
    ///            Пример: `1234.5678` → `"1234.57"`.
    func numberFormat(fractionLength: Int = 2) -> String {
        self.formatted(.number.precision(.fractionLength(fractionLength)))
    }
    
    /// Форматирует число как процент с указанной точностью дробной части.
    /// - Parameter fractionLength: Количество знаков после запятой. По умолчанию `2`.
    /// - Returns: Строковое представление числа в процентах.
    ///            Пример: `0.1234` → `"12.34%"`.
    func percentFormat(fractionLength: Int = 2) -> String {
        self.formatted(.percent.precision(.fractionLength(fractionLength)))
    }
}
