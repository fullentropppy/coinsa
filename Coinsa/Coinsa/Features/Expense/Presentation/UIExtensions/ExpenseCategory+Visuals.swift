//
//  ExpenseCategory+Visuals.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.04.2026.
//

import SwiftUI

extension ExpenseCategory: ValueVisualRepresentable {
    // MARK: - Свойства

    /// Основная иконка категории (контурная версия).
    var primaryIcon: String {
        switch self {
        case .food: AppSymbols.forkKnife
        case .transport: AppSymbols.car
        case .accommodation: AppSymbols.house
        case .leisure: AppSymbols.star
        case .shopping: AppSymbols.bag
        case .medicine: AppSymbols.cross
        case .miscellaneous: AppSymbols.circleGrid2x2
        }
    }
    
    /// Вторичная иконка категории (заливная версия).
    var secondaryIcon: String {
        switch self {
        case .food: AppSymbols.forkKnife
        case .transport: AppSymbols.carFill
        case .accommodation: AppSymbols.houseFill
        case .leisure: AppSymbols.starFill
        case .shopping: AppSymbols.bagFill
        case .medicine: AppSymbols.crossFill
        case .miscellaneous: AppSymbols.circleGrid2x2Fill
        }
    }
    
    /// Акцентный цвет категории.
    var accentColor: Color {
        switch self {
        case .food: .ExpenseCategories.food
        case .transport: .ExpenseCategories.transport
        case .accommodation: .ExpenseCategories.accommodation
        case .leisure: .ExpenseCategories.leisure
        case .shopping: .ExpenseCategories.shopping
        case .medicine: .ExpenseCategories.medicine
        case .miscellaneous: .ExpenseCategories.miscellaneous
        }
    }
}
