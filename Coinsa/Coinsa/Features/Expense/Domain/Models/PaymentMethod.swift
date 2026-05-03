//
//  PaymentMethod.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 12.04.2026.
//

/// Способ оплаты.
enum PaymentMethod: String, Codable, CaseIterable, Identifiable {
    // MARK: - Значения
    
    case cash
    case card
    
    // MARK: - Основные свойства
    
    var id: String { rawValue }
}
