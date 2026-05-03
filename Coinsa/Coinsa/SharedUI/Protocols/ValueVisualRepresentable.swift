//
//  ValueVisualRepresentable.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.04.2026.
//

import SwiftUI

/// Протокол для значений, определяющих визуальное представление.
protocol ValueVisualRepresentable {
    var primaryIcon: String { get }
    var secondaryIcon: String { get }
    var accentColor: Color { get }
}
