//
//  Currency+Sorting.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.03.2026.
//

import Foundation

extension Currency {
    static var allCasesSortedByName: [Currency] {
        allCases.sorted {
            let firstName = String(localized: $0.localized)
            let secondName = String(localized: $1.localized)
            return firstName.localizedCaseInsensitiveCompare(secondName) == .orderedAscending
        }
    }
}
