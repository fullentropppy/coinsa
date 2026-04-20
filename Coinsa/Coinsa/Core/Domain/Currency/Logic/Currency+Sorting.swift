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
            let name1 = String(localized: $0.localizedResource)
            let name2 = String(localized: $1.localizedResource)
            return name1.localizedCaseInsensitiveCompare(name2) == .orderedAscending
        }
    }
}
