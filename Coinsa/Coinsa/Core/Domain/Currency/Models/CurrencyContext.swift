//
//  CurrencyContext.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.03.2026.
//

import Foundation

/// Валюта контекста для ввода/вывода.
enum CurrencyContext: String, Identifiable {
    // MARK: - Значения
    
    case base
    case location
    case expense
    
    // MARK: - Основные свойства
    
    var id: String { rawValue }
}
