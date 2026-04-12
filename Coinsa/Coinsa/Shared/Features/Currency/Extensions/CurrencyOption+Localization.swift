//
//  Currency+Localization.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.03.2026.
//

import SwiftUI

extension Currency {
    var localizedResource: LocalizedStringResource {
        switch self {
        case .aed: .currencyNameAed
        case .byn: .currencyNameByn
        case .cny: .currencyNameCny
        case .eur: .currencyNameEur
        case .jpy: .currencyNameJpy
        case .krw: .currencyNameKrw
        case .kzt: .currencyNameKzt
        case .rub: .currencyNameRub
        case .try: .currencyNameTry
        case .usd: .currencyNameUsd
        }
    }
}
