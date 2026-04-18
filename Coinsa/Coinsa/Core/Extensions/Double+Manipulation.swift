//
//  Double+Manipulation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.03.2026.
//

import Foundation

extension Double {
    var nonNegative: Double {
        max(0, self)
    }
    
    func rounded(to places: Int = 2, rule: FloatingPointRoundingRule = .toNearestOrEven) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded(rule) / multiplier
    }
}
