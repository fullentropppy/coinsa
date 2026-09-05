//
//  ValueVisualRepresentable.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.04.2026.
//

import SwiftUI

// MARK: - Протокол

/// Протокол для значений, определяющих визуальное представление.
protocol ValueVisualRepresentable {
    var primaryIcon: String { get }
    var secondaryIcon: String { get }
    var accentColor: Color { get }
}

// MARK: - Стандартная реализация

extension ValueVisualRepresentable {
    var secondaryIcon: String { primaryIcon }
    var accentColor: Color { .primary }
}
