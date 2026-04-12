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
            let firstName = String(localized: $0.localizedResource)
            let secondName = String(localized: $1.localizedResource)
            return firstName.localizedCaseInsensitiveCompare(secondName) == .orderedAscending
        }
    }
}
