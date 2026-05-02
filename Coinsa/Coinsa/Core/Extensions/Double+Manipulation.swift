//
//  Double+Manipulation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.03.2026.
//

import Foundation

/// Манипуляции с числами с плавающей запятой.
extension Double {
    /// Гарантировано неотрицательное число.
    var nonNegative: Double {
        max(0, self)
    }
    
    /// Округляет число до указанного количества знаков после запятой.
    /// - Parameters:
    ///   - fractionLength: Количество знаков после запятой для сохранения. По умолчанию `2`.
    ///   - rule: Правило округления. По умолчанию `.toNearestOrEven`.
    /// - Returns: Округлённое число с заданной точностью.
    func rounded(to fractionLength: Int = 2, rule: FloatingPointRoundingRule = .toNearestOrEven) -> Double {
        let multiplier = pow(10.0, Double(fractionLength))
        return (self * multiplier).rounded(rule) / multiplier
    }
}
