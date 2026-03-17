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
            $0.localizedDisplayName.localizedCaseInsensitiveCompare($1.localizedDisplayName) == .orderedAscending
        }
    }
}
