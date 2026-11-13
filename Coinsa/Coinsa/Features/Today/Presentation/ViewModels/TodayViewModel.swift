//
//  TodayViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 11.04.2026.
//

import Foundation

/// ViewModel для выбора локации и загрузки справочного курса экрана «Сегодня».
@MainActor
@Observable
final class TodayViewModel {
    // MARK: - Зависимости

    private let exchangeRateProvider: ExchangeRateProvider

    // MARK: - Состояние

    private var loadedRate: (key: TodayRateRefreshKey, value: Double)?
    private var activeRequestID: UUID?

    // MARK: - Инициализация

    /// Создает состояние выбора локации и загрузки справочного курса.
    /// - Parameter exchangeRateProvider: Провайдер курсов; при `nil` создается провайдер с сервисом Hexarate.
    init(exchangeRateProvider: ExchangeRateProvider? = nil) {
        self.exchangeRateProvider = exchangeRateProvider ?? ExchangeRateProvider(service: HexarateService())
    }

    // MARK: - Выбор локации

    func selectedLocation(in locations: [Location], preferredID: UUID?) -> Location? {
        locations.first(where: { $0.id == preferredID }) ?? locations.first
    }

    func navigationTitle(for location: Location?, locationsCount: Int) -> String {
        if let location, locationsCount == 1 {
            location.name
        } else {
            String(localized: .today)
        }
    }

    // MARK: - Курс обмена

    func rateLocationToHome(for location: Location, key: TodayRateRefreshKey) -> Double {
        if let loadedRate, loadedRate.key == key {
            loadedRate.value
        } else {
            location.rateLocationToHome
        }
    }

    func refreshRate(for key: TodayRateRefreshKey?) async {
        guard !Task.isCancelled else { return }

        let requestID = UUID()
        activeRequestID = requestID
        loadedRate = nil

        guard let key, key.from != key.to else { return }

        do {
            let rate = try await exchangeRateProvider.getRate(from: key.from, to: key.to)
            try Task.checkCancellation()
            guard activeRequestID == requestID, rate.isFinite, rate > 0 else { return }
            loadedRate = (key, rate)
        } catch {
            return
        }
    }
}

/// Контекст запроса исключает использование курса другой локации или валютной пары.
struct TodayRateRefreshKey: Hashable {
    let locationID: UUID
    let from: Currency
    let to: Currency
    let updatedAt: Date
    let day: PlainDate

    /// Фиксирует локацию, валютную пару и день, к которым относится загружаемый курс.
    /// - Parameters:
    ///   - location: Локация, задающая идентификатор, валютную пару и дату обновления.
    ///   - day: Календарный день экрана, при смене которого курс запрашивается заново.
    init(location: Location, day: PlainDate) {
        locationID = location.id
        from = location.locationCurrency
        to = location.homeCurrency
        updatedAt = location.updatedAt
        self.day = day
    }
}
