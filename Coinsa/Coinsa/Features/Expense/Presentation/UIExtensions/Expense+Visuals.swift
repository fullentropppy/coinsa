//
//  Expense+Visuals.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

extension Expense: TypeVisualRepresentable {
    /// Основная иконка траты.
    static var primaryIcon: String { "cart" }
    
    /// Вторичная иконка траты.
    static var secondaryIcon: String { "cart.fill" }
    
    /// Акцентный цвет траты.
    static var accentColor: Color { .orange }
}
