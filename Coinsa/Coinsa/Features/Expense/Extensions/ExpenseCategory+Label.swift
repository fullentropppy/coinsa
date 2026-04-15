//
//  ExpenseCategory+Label.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import Foundation

extension ExpenseCategory: LabelProviding {
    var labelTitle: LocalizedStringResource {
        self.localizedResource
    }
    
    var labelIcon: String {
        switch self {
        case .food: "fork.knife"
        case .transport: "car"
        case .activity: "sparkles.2"
        case .shopping: "bag"
        case .medicine: "pills"
        case .other: "circle.grid.2x2"
        }
    }
}
