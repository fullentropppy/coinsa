//
//  PreviewLocale.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.03.2026.
//

import Foundation

enum PreviewLocale: String {
    // MARK: - Cases
    
    case en = "en" // English
    case ru = "ru" // Russian
    
    // MARK: - Computed Properties
    
    var locale: Locale {
        Locale(identifier: rawValue)
    }
}
