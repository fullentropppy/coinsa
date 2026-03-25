//
//  Trip+Calculation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.03.2026.
//

import Foundation

extension Trip {
    func calculatePlannedAmount(inBase: Bool = true) -> Double {
        locations.reduce(0) {
            $0 + $1.calculatePlannedAmount(asBaseCurrency: inBase)
        }
    }
    
    func calculateActualAmount(inBase: Bool = true) -> Double {
        locations.reduce(0) {
            $0 + $1.calculateActualAmount(asBaseCurrency: inBase)
        }
    }
}
