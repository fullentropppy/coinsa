//
//  NumericEditField.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 12.11.2026.
//

/// Идентификаторы полей для управления фокусом в числовых вводах.
nonisolated enum NumericEditField: Hashable {
    case amount
    case exchangeRate
    case locationExchangeRate
    case exchangeAdjustment
    case budget
    case converterFromAmount
    case converterToAmount
}
