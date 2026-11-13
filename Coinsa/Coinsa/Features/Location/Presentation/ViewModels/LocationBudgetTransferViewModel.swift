//
//  LocationBudgetTransferViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.11.2026.
//

import Foundation
import Observation
import SwiftData

/// Состояние выбора получателя и подтверждения переноса остатка бюджета.
@MainActor
@Observable
final class LocationBudgetTransferViewModel {
    struct Selection {
        let destination: Location
        let homeAmount: Double
        let homeCurrencyCode: String
        let message: LocalizedStringResource
    }

    let source: Location
    var selection: Selection?
    var isShowingConfirmation = false
    var errorMessage: LocalizedStringResource?

    var availableHomeAmount: Double {
        LocationBudgetTransfer.availableHomeAmount(from: source) ?? 0
    }

    var availableLocationAmount: Double {
        source.calculateBudgetBalance(in: .location)
    }

    var groupedLocations: [(status: EventStatus, locations: [Location])] {
        LocationGrouping.grouped(Self.destinations(for: source))
    }

    var canTransfer: Bool {
        Self.canTransfer(from: source)
    }

    /// Создает состояние переноса для существующей локации.
    /// - Parameter source: Локация, передающая положительный остаток бюджета.
    init(source: Location) {
        self.source = source
    }

    static func canTransfer(from source: Location) -> Bool {
        !source.isDeleted
            && source.trip?.isDeleted == false
            && LocationBudgetTransfer.availableHomeAmount(from: source) != nil
            && !destinations(for: source).isEmpty
    }

    func select(_ destination: Location) {
        guard canTransfer, let trip = source.trip else { return }

        let amount = availableHomeAmount
        selection = Selection(
            destination: destination,
            homeAmount: amount,
            homeCurrencyCode: trip.baseCurrencyCode,
            message: .locationBudgetTransferConfirmationMessage(
                sourceName: source.name,
                destinationName: destination.name
            )
        )
        isShowingConfirmation = true
    }

    func transfer(_ selection: Selection, using repository: LocationRepository) -> Double? {
        do {
            return try repository.transferBudget(
                from: source,
                to: selection.destination,
                expectedHomeAmount: selection.homeAmount,
                expectedHomeCurrencyCode: selection.homeCurrencyCode
            )
        } catch let error as LocationBudgetTransfer.ValidationError {
            switch error {
            case .invalidLocations:
                errorMessage = .locationBudgetTransferErrorLocations
            case .invalidAmounts:
                errorMessage = .locationBudgetTransferErrorAmounts
            case .balanceChanged:
                errorMessage = .locationBudgetTransferErrorBalanceChanged
            }
        } catch {
            errorMessage = .locationBudgetTransferErrorSave
        }

        return nil
    }

    private static func destinations(for source: Location) -> [Location] {
        guard let trip = source.trip, !trip.isDeleted else { return [] }

        return (trip.locations ?? []).filter {
            $0.id != source.id && !$0.isDeleted && $0.trip === trip
        }
    }
}
