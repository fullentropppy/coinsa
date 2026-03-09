//
//  LocalizationKeyProviding.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.03.2026.
//

import SwiftUI

// MARK: - Protocol

protocol LocalizationKeyProviding: RawRepresentable where RawValue == String {
    static var localizationKeyPrefix: String { get }
}

// MARK: - Default Implementation

extension LocalizationKeyProviding {
    private var localizationKey: String {
        "\(Self.localizationKeyPrefix).\(rawValue.lowercased())"
    }

    var localizedKey: LocalizedStringKey {
        LocalizedStringKey(localizationKey)
    }

    var localizedDisplayName: String {
        String(localized: String.LocalizationValue(localizationKey))
    }
}
