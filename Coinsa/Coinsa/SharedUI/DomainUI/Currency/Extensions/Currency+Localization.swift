//
//  Currency+Localization.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.03.2026.
//

import Foundation

extension Currency: LocalizedResourceProviding {
    // MARK: - Свойства

    /// Локализованное название валюты.
    var localizedResource: LocalizedStringResource {
        switch self {
        case .aed: .currencyNameAed
        case .amd: .currencyNameAmd
        case .ars: .currencyNameArs
        case .aud: .currencyNameAud
        case .azn: .currencyNameAzn
        case .bam: .currencyNameBam
        case .brl: .currencyNameBrl
        case .byn: .currencyNameByn
        case .cad: .currencyNameCad
        case .chf: .currencyNameChf
        case .cny: .currencyNameCny
        case .cop: .currencyNameCop
        case .czk: .currencyNameCzk
        case .dkk: .currencyNameDkk
        case .egp: .currencyNameEgp
        case .eur: .currencyNameEur
        case .gbp: .currencyNameGbp
        case .gel: .currencyNameGel
        case .hkd: .currencyNameHkd
        case .huf: .currencyNameHuf
        case .idr: .currencyNameIdr
        case .ils: .currencyNameIls
        case .inr: .currencyNameInr
        case .isk: .currencyNameIsk
        case .jod: .currencyNameJod
        case .jpy: .currencyNameJpy
        case .kes: .currencyNameKes
        case .kgs: .currencyNameKgs
        case .khr: .currencyNameKhr
        case .krw: .currencyNameKrw
        case .kzt: .currencyNameKzt
        case .lak: .currencyNameLak
        case .lkr: .currencyNameLkr
        case .mad: .currencyNameMad
        case .mop: .currencyNameMop
        case .mur: .currencyNameMur
        case .mvr: .currencyNameMvr
        case .mxn: .currencyNameMxn
        case .myr: .currencyNameMyr
        case .nok: .currencyNameNok
        case .nzd: .currencyNameNzd
        case .omr: .currencyNameOmr
        case .pen: .currencyNamePen
        case .php: .currencyNamePhp
        case .pln: .currencyNamePln
        case .qar: .currencyNameQar
        case .ron: .currencyNameRon
        case .rsd: .currencyNameRsd
        case .rub: .currencyNameRub
        case .sar: .currencyNameSar
        case .scr: .currencyNameScr
        case .sek: .currencyNameSek
        case .sgd: .currencyNameSgd
        case .thb: .currencyNameThb
        case .tjs: .currencyNameTjs
        case .tnd: .currencyNameTnd
        case .try: .currencyNameTry
        case .twd: .currencyNameTwd
        case .tzs: .currencyNameTzs
        case .uah: .currencyNameUah
        case .usd: .currencyNameUsd
        case .uzs: .currencyNameUzs
        case .vnd: .currencyNameVnd
        case .zar: .currencyNameZar
        }
    }
}
