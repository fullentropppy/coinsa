//
//  Currency+Localization.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.03.2026.
//

import Foundation

extension Currency: LocalizedResourceProviding {
    var localizedResource: LocalizedStringResource {
        switch self {
        case .aed: .currencyNameAed
        case .amd: .currencyNameAmd
        case .ars: .currencyNameArs
        case .aud: .currencyNameAud
        case .azn: .currencyNameAzn
        case .bgn: .currencyNameBgn
        case .brl: .currencyNameBrl
        case .byn: .currencyNameByn
        case .cad: .currencyNameCad
        case .cny: .currencyNameCny
        case .cop: .currencyNameCop
        case .czk: .currencyNameCzk
        case .dkk: .currencyNameDkk
        case .egp: .currencyNameEgp
        case .eur: .currencyNameEur
        case .gbp: .currencyNameGbp
        case .gel: .currencyNameGel
        case .hkd: .currencyNameHkd
        case .hrk: .currencyNameHrk
        case .huf: .currencyNameHuf
        case .idr: .currencyNameIdr
        case .ils: .currencyNameIls
        case .inr: .currencyNameInr
        case .jpy: .currencyNameJpy
        case .krw: .currencyNameKrw
        case .kzt: .currencyNameKzt
        case .mad: .currencyNameMad
        case .mop: .currencyNameMop
        case .mxn: .currencyNameMxn
        case .myr: .currencyNameMyr
        case .nok: .currencyNameNok
        case .php: .currencyNamePhp
        case .pln: .currencyNamePln
        case .qar: .currencyNameQar
        case .rub: .currencyNameRub
        case .sar: .currencyNameSar
        case .sek: .currencyNameSek
        case .sgd: .currencyNameSgd
        case .thb: .currencyNameThb
        case .try: .currencyNameTry
        case .usd: .currencyNameUsd
        case .uzs: .currencyNameUzs
        case .vnd: .currencyNameVnd
        case .zar: .currencyNameZar
        }
    }
}
