//
//  Location+Visuals.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

extension Location: TypeVisualRepresentable {
    // MARK: - Свойства

    /// Основная иконка локации.
    static var primaryIcon: String { AppSymbols.mappinAndEllipse }
    
    /// Вторичная иконка локации.
    static var secondaryIcon: String { primaryIcon }
}
