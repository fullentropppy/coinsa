//
//  ExpenseCategory.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

/// Категории трат.
enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
    // MARK: - Значения
    
    case food
    case transport
    case activity
    case shopping
    case medicine
    case other
    
    // MARK: - Базовые свойства
    
    var id: String { rawValue }
}
