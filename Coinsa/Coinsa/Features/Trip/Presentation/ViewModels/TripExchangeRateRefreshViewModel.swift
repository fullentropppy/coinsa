//
//  TripExchangeRateRefreshViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.11.2026.
//

import Foundation
import Observation

/// Загрузка курсов текущих и предстоящих локаций и сообщение о результате сохранения.
@MainActor
@Observable
final class TripExchangeRateRefreshViewModel {
    // MARK: - Вложенные типы

    private enum LoadingFailure: CaseIterable {
        case timeout
        case network
        case invalidRate
        case provider

        func message(locations: [String]) -> LocalizedStringResource {
            let names = locations.sorted().joined(separator: ", ")
            return switch self {
            case .timeout: .tripRatesRefreshErrorTimeoutMessage(locations: names)
            case .network: .tripRatesRefreshErrorNetworkMessage(locations: names)
            case .invalidRate: .tripRatesRefreshErrorInvalidRateMessage(locations: names)
            case .provider: .tripRatesRefreshErrorLoadingMessage(locations: names)
            }
        }
    }

    // MARK: - Свойства

    private let provider: ExchangeRateProvider

    var isRefreshing = false
    var isShowingResult = false
    var isError = false
    var message: LocalizedStringResource?

    // MARK: - Инициализация

    /// Создает состояние обновления с общим провайдером для всех валют поездки.
    /// - Parameter exchangeRateProvider: Провайдер курсов; при nil используется Hexarate.
    init(exchangeRateProvider: ExchangeRateProvider? = nil) {
        provider = exchangeRateProvider ?? ExchangeRateProvider(service: HexarateService())
    }

    // MARK: - Методы

    func refresh(in trip: Trip, using repository: LocationRepository) async {
        guard !isRefreshing, !Task.isCancelled else { return }
        isRefreshing = true
        isShowingResult = false
        message = nil
        defer { isRefreshing = false }

        let targets = LocationExchangeRateUpdate.availableLocations(in: trip)
            .map { LocationExchangeRateUpdate.Target(location: $0) }
        guard !targets.isEmpty else {
            showError(.tripRatesRefreshErrorUnavailableLocationsMessage)
            return
        }

        let homeCurrency = trip.homeCurrency
        let homeCurrencyCode = trip.baseCurrencyCode
        let groups = Dictionary(grouping: targets, by: \.currency)
        var updates: [LocationExchangeRateUpdate] = []
        var failures: [LoadingFailure: [String]] = [:]

        for currency in groups.keys.sorted(by: { $0.code < $1.code }) {
            guard !Task.isCancelled else { return }
            let group = groups[currency] ?? []
            let names = group.map(\.name)

            do {
                let rate = currency == homeCurrency
                    ? 1
                    : try await provider.getRate(from: currency, to: homeCurrency)
                guard !Task.isCancelled else { return }
                guard rate.isFinite, rate > 0 else {
                    failures[.invalidRate, default: []] += names
                    continue
                }

                updates += group.map { LocationExchangeRateUpdate(target: $0, rate: rate) }
            } catch {
                guard !Task.isCancelled else { return }
                let reason: LoadingFailure
                if error is TimeoutError || (error as? URLError)?.code == .timedOut {
                    reason = .timeout
                } else if error is URLError {
                    reason = .network
                } else {
                    reason = .provider
                }
                failures[reason, default: []] += names
            }
        }

        guard !Task.isCancelled else { return }

        if !updates.isEmpty {
            do {
                try repository.updateExchangeRates(updates, in: trip, expectedHomeCurrencyCode: homeCurrencyCode)
            } catch let error as LocationExchangeRateUpdate.ValidationError {
                switch error {
                case .unavailableLocations:
                    showError(.tripRatesRefreshErrorUnavailableLocationsMessage)
                case .dataChanged:
                    showError(.tripRatesRefreshErrorDataChangedMessage)
                case .invalidRate:
                    showError(.tripRatesRefreshErrorInvalidRateMessage(
                        locations: updates.map { $0.target.name }.sorted().joined(separator: ", ")
                    ))
                }
                return
            } catch {
                showError(.tripRatesRefreshErrorSaveMessage)
                return
            }
        }

        if failures.isEmpty {
            isError = false
            message = .tripRatesRefreshSuccessMessage
            isShowingResult = true
        } else {
            let details = LoadingFailure.allCases.compactMap { reason -> String? in
                guard let names = failures[reason] else { return nil }
                return String(localized: reason.message(locations: names))
            }.joined(separator: "\n\n")
            showError(updates.isEmpty
                ? .tripRatesRefreshErrorMessage(details: details)
                : .tripRatesRefreshErrorPartialMessage(details: details))
        }
    }

    // MARK: - Приватные методы

    private func showError(_ message: LocalizedStringResource) {
        isError = true
        self.message = message
        isShowingResult = true
    }
}
