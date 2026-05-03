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
        case .activity: "sparkles.2"
        case .shopping: "bag"
        case .medicine: "pills"
        case .other: "circle.grid.2x2"
        }
    }
    
    /// Вторичная иконка категории (заливная версия).
    var secondaryIcon: String {
        switch self {
        case .food: "fork.knife"
        case .transport: "car.fill"
        case .activity: "sparkles.2"
        case .shopping: "bag.fill"
        case .medicine: "pills.fill"
        case .other: "circle.grid.2x2.fill"
        }
    }
    
    /// Акцентный цвет категории.
    var accentColor: Color {
        switch self {
        case .food: .mint
        case .transport: .blue
        case .activity: .yellow
        case .shopping: .red
        case .medicine: .cyan
        case .other: .brown
        }
    }
}
