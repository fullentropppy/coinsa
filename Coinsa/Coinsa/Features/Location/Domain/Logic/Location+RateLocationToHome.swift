//
//  Location+RateLocationToHome.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.11.2026.
//

extension Location {
    // MARK: - Свойства

    /// Курс обмена валюты локации к домашней валюты.
    /// На переходный период для переименования rateLocationToBase в rateLocationToHome.
    var rateLocationToHome: Double {
        rateLocationToBase
    }
}
