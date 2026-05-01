//
//  Int+Comparison.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 21.04.2026.
//

import Foundation

/// Сравнение целочисленных значений.
extension Int {
    /// Определяет, находится ли целое число в заданном интервале (включительно).
    /// - Parameters:
    ///   - first: Левая граница интервала.
    ///   - second: Правая граница интервала.
    /// - Returns: `true`, если число находится в интервале.
    func isBetween(_ first: Int, and second: Int) -> Bool {
        self >= first && self <= second || self >= second && self <= first
    }
}
