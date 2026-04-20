//
//  PaymentMethod+Visuals.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.04.2026.
//

import SwiftUI

extension PaymentMethod: ValueVisualRepresentable {
    var primaryIcon: String {
        switch self {
        case .cash: "banknote"
        case .card: "creditcard"
        }
    }
    
    var secondaryIcon: String {
        switch self {
        case .cash: "banknote.fill"
        case .card: "creditcard.fill"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .cash: .green
        case .card: .blue
        }
    }
}
