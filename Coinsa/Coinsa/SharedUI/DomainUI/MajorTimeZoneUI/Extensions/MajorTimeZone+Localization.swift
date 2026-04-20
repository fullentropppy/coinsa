//
//  MajorTimeZone+Localization.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 19.04.2026.
//

import Foundation

extension MajorTimeZone: LocalizedResourceProviding {
    var localizedResource: LocalizedStringResource {
        switch self {
        case .honolulu: .majorTimeZoneNameHonolulu
        case .anchorage: .majorTimeZoneNameAnchorage
        case .losAngeles: .majorTimeZoneNameLosAngeles
        case .denver: .majorTimeZoneNameDenver
        case .chicago: .majorTimeZoneNameChicago
        case .newYork: .majorTimeZoneNameNewYork
        case .halifax: .majorTimeZoneNameHalifax
        case .saoPaulo: .majorTimeZoneNameSaoPaulo
        case .stJohns: .majorTimeZoneNameStJohns
            
        case .azores: .majorTimeZoneNameAzores
        case .london: .majorTimeZoneNameLondon
        case .paris: .majorTimeZoneNameParis
        case .athens: .majorTimeZoneNameAthens
        case .moscow: .majorTimeZoneNameMoscow
            
        case .tehran: .majorTimeZoneNameTehran
        case .dubai: .majorTimeZoneNameDubai
        case .karachi: .majorTimeZoneNameKarachi
        case .kolkata: .majorTimeZoneNameKolkata
        case .kathmandu: .majorTimeZoneNameKathmandu
        case .dhaka: .majorTimeZoneNameDhaka
            
        case .bangkok: .majorTimeZoneNameBangkok
        case .shanghai: .majorTimeZoneNameShanghai
        case .tokyo: .majorTimeZoneNameTokyo
            
        case .adelaide: .majorTimeZoneNameAdelaide
        case .sydney: .majorTimeZoneNameSydney
        case .auckland: .majorTimeZoneNameAuckland
        case .tonga: .majorTimeZoneNameTongatapu
        }
    }
}
