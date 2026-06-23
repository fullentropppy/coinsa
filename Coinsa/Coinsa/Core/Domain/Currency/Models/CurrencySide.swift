//
//  CurrencySide.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.06.2026.
//

import Foundation

/// Сторона валютной пары.
enum CurrencySide: String, Identifiable {
    // MARK: - Значения
    
    case base
    case quote
    
    // MARK: - Основные свойства
    
    var id: String { rawValue }
}
