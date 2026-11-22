//
//  Expense+Visuals.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

extension Expense: TypeVisualRepresentable {
    // MARK: - Свойства

    /// Основная иконка траты.
    static var primaryIcon: String { AppSymbols.cart }
    
    /// Вторичная иконка траты.
    static var secondaryIcon: String { AppSymbols.cartFill }
}
