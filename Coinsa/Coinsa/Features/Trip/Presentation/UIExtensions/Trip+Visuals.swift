//
//  Trip+Visuals.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

extension Trip: TypeVisualRepresentable {
    // MARK: - Свойства

    /// Основная иконка поездки (контурная).
    static var primaryIcon: String { AppSymbols.suitcase }
    
    /// Вторичная иконка поездки (заливная).
    static var secondaryIcon: String { AppSymbols.suitcaseFill }
}
