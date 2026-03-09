//
//  AppTheme.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

enum AppTheme: String, CaseIterable, Identifiable {
    // MARK: - Cases
    
    case system
    case light
    case dark

    // MARK: - Computed Properties
    
    var id: String { rawValue }
}
