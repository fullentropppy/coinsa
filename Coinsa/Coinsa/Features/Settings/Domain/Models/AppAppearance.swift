//
//  AppAppearance.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

enum AppAppearance: String, CaseIterable, Identifiable {
    // MARK: - Значения
    
    case system
    case light
    case dark

    // MARK: - Основные свойства
    
    var id: String { rawValue }
}
