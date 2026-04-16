//
//  Trip+Calculation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.03.2026.
//

import Foundation

extension Trip {
    func calculatePlannedAmount(asBaseCurrency: Bool = true) -> Double {
        locations.reduce(0) {
            $0 + $1.calculatePlannedAmount(asBaseCurrency: asBaseCurrency)
        }
    }
    
    func calculateActualAmount(asBaseCurrency: Bool = true) -> Double {
        locations.reduce(0) {
            $0 + $1.calculateActualAmount(asBaseCurrency: asBaseCurrency)
        }
    }
}
