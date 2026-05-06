//
//  Budget+Visuals.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 05.05.2026.
//

import SwiftUI

extension Budget: TypeVisualRepresentable {
    /// Основная иконка локации.
    static var primaryIcon: String { "wallet.bifold" }
    
    /// Вторичная иконка локации.
    static var secondaryIcon: String { "wallet.bifold.fill" }
    
    /// Акцентный цвет для локации.
    static var accentColor: Color { .green }
}
