//
//  Expense+Visuals.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

extension Expense: TypeVisualRepresentable {
    static var primaryIcon: String { "cart" }
    static var secondaryIcon: String { "cart.fill" }
    static var accentColor: Color { .orange }
}
