//
//  Trip+Visuals.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

extension Trip: TypeVisualRepresentable {
    /// Основная иконка поездки (контурная).
    static var primaryIcon: String { "suitcase" }
    
    /// Вторичная иконка поездки (заливная).
    static var secondaryIcon: String { "suitcase.fill" }
    
    /// Акцентный цвет для поездки.
    static var accentColor: Color { .indigo }
}
