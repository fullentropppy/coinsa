//
//  PaymentMethod+Visuals.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.04.2026.
//

import SwiftUI

extension PaymentMethod: ValueVisualRepresentable {
    /// Основная иконка способа оплаты (контурная версия).
    var primaryIcon: String {
        switch self {
        case .cash: "banknote"
        case .card: "creditcard"
        }
    }
    
    /// Вторичная иконка способа оплаты (заливная версия).
    var secondaryIcon: String {
        switch self {
        case .cash: "banknote.fill"
        case .card: "creditcard.fill"
        }
    }
    
    /// Акцентный цвет способа оплаты.
    var accentColor: Color {
        switch self {
        case .cash: .green
        case .card: .blue
        }
    }
}
