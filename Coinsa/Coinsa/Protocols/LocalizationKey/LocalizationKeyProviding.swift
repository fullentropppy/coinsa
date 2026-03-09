//
//  LocalizationKeyProviding.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.03.2026.
//

import Foundation

// MARK: - Protocol

protocol LocalizationKeyProviding: RawRepresentable where RawValue == String {
    static var localizationKeyPrefix: String { get }
}

// MARK: - Default Implementation

extension LocalizationKeyProviding {
    var localizationKey: String {
        "\(Self.localizationKeyPrefix).\(rawValue.lowercased())"
    }

    var localizedDisplayName: String {
        String(localized: String.LocalizationValue(localizationKey))
    }
}
