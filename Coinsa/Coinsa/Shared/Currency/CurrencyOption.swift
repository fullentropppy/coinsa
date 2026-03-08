//
//  CurrencyOption.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import Foundation
import SwiftUI

enum CurrencyOption: String, CaseIterable, Identifiable {
    case usd = "USD"
    case eur = "EUR"
    case rub = "RUB"

    var id: String { rawValue }

    var code: String { rawValue }

    var localizedNameKey: LocalizedStringKey {
        LocalizedStringKey("currency.name." + rawValue.lowercased())
    }

    static var defaultOption: CurrencyOption {
        let localeCode = Locale.current.currency?.identifier ?? "USD"
        return CurrencyOption(rawValue: localeCode) ?? .usd
    }

    static func from(code: String) -> CurrencyOption {
        CurrencyOption(rawValue: code.uppercased()) ?? .usd
    }
}
