//
//  CurrencyOption+Sorting.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.03.2026.
//

import Foundation

extension CurrencyOption {
    static var allCasesSortedByName: [CurrencyOption] {
        allCases.sorted {
            $0.localizedDisplayName.localizedCaseInsensitiveCompare($1.localizedDisplayName) == .orderedAscending
        }
    }
}
