//
//  CategoryAmountMode.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.08.2026.
//

// Режимы отображения трат по категориям.
enum CategoryAmountMode: String, CaseIterable, Identifiable {
    // MARK: - Значения
    
    case total
    case daily
    
    // MARK: - Основные свойства
    
    var id: String { rawValue }
}
