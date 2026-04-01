//
//  AppSettings.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import Foundation
import SwiftData

@Model
final class AppSettings {
    // MARK: - Stored Properties

    var baseCurrencyCode: String
    
    // MARK: - Initialization

    init(baseCurrencyCode: String) {
        self.baseCurrencyCode = baseCurrencyCode
    }
}
