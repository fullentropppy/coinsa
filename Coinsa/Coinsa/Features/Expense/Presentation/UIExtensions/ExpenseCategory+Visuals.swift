//
//  ExpenseCategory+Visuals.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.04.2026.
//

import SwiftUI

extension ExpenseCategory: ValueVisualRepresentable {
    /// Основная иконка категории (контурная версия).
    var primaryIcon: String {
        switch self {
        case .food: "fork.knife"
        case .transport: "car"
        case .accommodation: "house"
        case .leisure: "star"
        case .shopping: "bag"
        case .medicine: "cross"
        case .miscellaneous: "circle.grid.2x2"
        }
    }
    
    /// Вторичная иконка категории (заливная версия).
    var secondaryIcon: String {
        switch self {
        case .food: "fork.knife"
        case .transport: "car.fill"
        case .accommodation: "house.fill"
        case .leisure: "star.fill"
        case .shopping: "bag.fill"
        case .medicine: "cross.fill"
        case .miscellaneous: "circle.grid.2x2.fill"
        }
    }
    
    /// Акцентный цвет категории.
    var accentColor: Color {
        switch self {
        case .food: .mint
        case .transport: .blue
        case .accommodation: .green
        case .leisure: .yellow
        case .shopping: .red
        case .medicine: .cyan
        case .miscellaneous: .brown
        }
    }
}
