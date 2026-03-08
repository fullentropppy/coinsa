//
//  CurrencyOption.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import Foundation
import SwiftUI

enum CurrencyOption: String, CaseIterable, Identifiable {
    // MARK: - Cases

    case aed = "AED"
    case amd = "AMD"
    case azn = "AZN"
    case byn = "BYN"
    case cny = "CNY"
    case eur = "EUR"
    case gbp = "GBP"
    case gel = "GEL"
    case hkd = "HKD"
    case idr = "IDR"
    case jpy = "JPY"
    case krw = "KRW"
    case kzt = "KZT"
    case mop = "MOP"
    case myr = "MYR"
    case rub = "RUB"
    case sgd = "SGD"
    case thb = "THB"
    case `try` = "TRY"
    case usd = "USD"
    case uzs = "UZS"
    case vnd = "VND"

    // MARK: - Stored Properties
    
    var id: String { rawValue }
    var code: String { rawValue }

    // MARK: - Computed Properties
    
    var localizedDisplayName: String {
        let key = "currency.name.\(rawValue.lowercased())"
        return String(localized: String.LocalizationValue(key))
    }

    // MARK: - Computed Static Properties
    
    static var allCasesSortedByName: [CurrencyOption] {
        allCases.sorted {
            $0.localizedDisplayName.localizedCaseInsensitiveCompare($1.localizedDisplayName) == .orderedAscending
        }
    }
    
    // MARK: - Public Static Methods
    
    static func from(code: String) -> CurrencyOption {
        CurrencyOption(rawValue: code.uppercased()) ?? .usd
    }
    
    static var defaultOption: CurrencyOption {
        let localeCode = Locale.current.currency?.identifier ?? CurrencyOption.usd.code
        return CurrencyOption(rawValue: localeCode) ?? .usd
    }
}
