//
//  RateMode.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.06.2026.
//

import Foundation

// Режим курса обмена.
enum RateMode: String, Identifiable {
    // MARK: - Значения
    
    case actual
    case effective
    
    // MARK: - Основные свойства
    
    var id: String { rawValue }
}
