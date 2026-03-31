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
    var isPrimaryAddButtonOnLeft: Bool
    
    // MARK: - Initialization

    init(
        baseCurrencyCode: String,
        isPrimaryAddButtonOnLeft: Bool
    ) {
        self.baseCurrencyCode = baseCurrencyCode
        self.isPrimaryAddButtonOnLeft = isPrimaryAddButtonOnLeft
    }
}
