//
//  LocationExchangeRateUpdate.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.11.2026.
//

import Foundation
import SwiftData

/// Загруженный курс и исходное состояние локации для проверки перед записью.
struct LocationExchangeRateUpdate {
    // MARK: - Вложенные типы

    enum ValidationError: Error {
        case unavailableLocations
        case dataChanged
        case invalidRate
    }

    struct Target {
        let location: Location
        let name: String
        let currency: Currency
        let currencyCode: String
        let updatedAt: Date

        /// Фиксирует валюту и версию локации до асинхронной загрузки курса.
        /// - Parameter location: Текущая или предстоящая локация поездки.
        init(location: Location) {
            self.location = location
            name = location.name
            currency = location.locationCurrency
            currencyCode = location.locationCurrencyCode
            updatedAt = location.updatedAt
        }
    }

    // MARK: - Свойства

    let target: Target
    let rate: Double

    // MARK: - Методы

    static func availableLocations(in trip: Trip, on day: PlainDate = .today) -> [Location] {
        guard !trip.isDeleted, let context = trip.modelContext else { return [] }

        return (trip.locations ?? []).filter {
            !$0.isDeleted && $0.modelContext === context && $0.trip === trip && $0.endPlainDate >= day
        }
    }
}
