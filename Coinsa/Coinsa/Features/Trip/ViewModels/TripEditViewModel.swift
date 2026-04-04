//
//  TripEditViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class TripEditViewModel {
    // MARK: - Stored Properties

    private let initialSnapshot: Snapshot
    
    let trip: Trip?
    
    var name: String
    var startDate: Date {
        didSet {
            if endDate < startDate {
                endDate = startDate
            }
        }
    }
    var endDate: Date
    var locations: [Location]

    // MARK: - Computed Properties

    var isEditing: Bool {
        trip != nil
    }

    var navigationTitle: LocalizedStringResource {
        isEditing ? .tripNavigationTitleEdit : .tripNavigationTitleCreate
    }

    var hasChanges: Bool {
        Snapshot(viewModel: self) != initialSnapshot
    }

    var canSave: Bool {
        !name.isBlank && startDate <= endDate
    }

    // MARK: - Initialization

    init(trip: Trip?) {
        self.trip = trip

        let resolvedName: String
        let resolvedStartDate: Date
        let resolvedEndDate: Date
        let resolvedLocations: [Location]

        if let trip {
            resolvedName = trip.name
            resolvedStartDate = trip.startDate
            resolvedEndDate = trip.endDate
            resolvedLocations = trip.locations
        } else {
            resolvedName = ""
            resolvedStartDate = .now.startOfDay
            resolvedEndDate = .now.endOfDay
            resolvedLocations = []
        }

        name = resolvedName
        startDate = resolvedStartDate
        endDate = resolvedEndDate
        locations = resolvedLocations

        initialSnapshot = Snapshot(
            name: resolvedName,
            startDate: resolvedStartDate,
            endDate: resolvedEndDate
        )
    }

    // MARK: - Public Methods

    func save(using repository: TripRepository) {
        if let trip {
            repository.update(
                trip,
                name: name,
                startDate: startDate,
                endDate: endDate
            )
        } else {
            repository.add(
                name: name,
                startDate: startDate,
                endDate: endDate
            )
        }
    }
}

// MARK: - Snapshot

private extension TripEditViewModel {
    struct Snapshot: Equatable {
        // MARK: - Stored Properties

        let name: String
        let startDate: Date
        let endDate: Date

        // MARK: - Initialization

        init(name: String, startDate: Date, endDate: Date) {
            self.name = name.trimmed
            self.startDate = startDate
            self.endDate = endDate
        }

        init(viewModel: TripEditViewModel) {
            self.init(
                name: viewModel.name,
                startDate: viewModel.startDate,
                endDate: viewModel.endDate
            )
        }
    }
}
