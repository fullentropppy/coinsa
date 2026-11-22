//
//  PaymentMethod+Visuals.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.04.2026.
//

extension PaymentMethod: ValueVisualRepresentable {
    // MARK: - Свойства

    /// Основная иконка способа оплаты (контурная версия).
    var primaryIcon: String {
        switch self {
        case .cash: AppSymbols.banknote
        case .card: AppSymbols.creditcard
        }
    }
    
    /// Вторичная иконка способа оплаты (заливная версия).
    var secondaryIcon: String {
        switch self {
        case .cash: AppSymbols.banknoteFill
        case .card: AppSymbols.creditcardFill
        }
    }
}
