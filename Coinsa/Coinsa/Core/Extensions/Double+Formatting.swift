//
//  Double+Formatting.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.04.2026.
//

import Foundation

extension Double {
    func numberFormat(fractionLength: Int = 2) -> String {
        self.formatted(.number.precision(.fractionLength(fractionLength)))
    }

    func percentFormat(fractionLength: Int = 2) -> String {
        self.formatted(.percent.precision(.fractionLength(fractionLength)))
    }
}
