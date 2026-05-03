//
//  Location+Visuals.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

extension Location: TypeVisualRepresentable {
    /// Основная иконка локации.
    static var primaryIcon: String { "mappin.and.ellipse" }
    
    /// Вторичная иконка локации.
    static var secondaryIcon: String { primaryIcon }
    
    /// Акцентный цвет для локации.
    static var accentColor: Color { .pink }
}
