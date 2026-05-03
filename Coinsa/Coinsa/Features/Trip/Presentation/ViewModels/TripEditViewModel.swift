//
//  TripEditViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation
import Observation

/// ViewModel для экрана создания/редактирования поездки.
@MainActor
@Observable
final class TripEditViewModel {
    // MARK: - Внутреннее состояние

    private let initialSnapshot: Snapshot
    
    // MARK: - Зависимости
    
    let trip: Trip?
    
    // MARK: - Состояние UI. Общее поведение и оформление
    
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

    var hasLocations: Bool {
        trip?.hasLocations ?? false
    }
    
    // MARK: - Состояние UI. Общие данные
    
    var name: String
    var startDate: Date {
        didSet {
            if endDate < startDate {
                endDate = startDate
            }
        }
    }
    var endDate: Date
    var baseCurrency: Currency
    
    // MARK: - Инициализация

    /// Создает ViewModel для новой поездки.
    /// - Parameter baseCurrency: Основная валюта по умолчанию.
    convenience init(forCreateWith baseCurrency: Currency) {
        self.init(
            trip: nil,
            name: "",
            startDate: .now.startOfDay,
            endDate: .now.endOfDay,
            baseCurrency: baseCurrency
        )
    }
    
    /// Создает ViewModel для редактирования существующей поездки.
    /// - Parameter trip: Редактируемая поездка.
    convenience init(forEdit trip: Trip) {
        self.init(
            trip: trip,
            name: trip.name,
            startDate: trip.startDate,
            endDate: trip.endDate,
            baseCurrency: trip.baseCurrency
        )
    }

    private init(
        trip: Trip?,
        name: String,
        startDate: Date,
        endDate: Date,
        baseCurrency: Currency
    ) {
        self.trip = trip
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.baseCurrency = baseCurrency
        
        self.initialSnapshot = Snapshot(
            name: name,
            startDate: startDate,
            endDate: endDate,
            baseCurrency: baseCurrency
        )
    }
    
    // MARK: - Операции с хранилищем

    func save(using repository: TripRepository) {
        if let trip {
            repository.update(
                trip,
                name: name,
                startDate: startDate,
                endDate: endDate,
                baseCurrency: baseCurrency
            )
        } else {
            repository.add(
                name: name,
                startDate: startDate,
                endDate: endDate,
                baseCurrency: baseCurrency
            )
        }
    }
}

// MARK: - Внутренние типы

private extension TripEditViewModel {
    /// Снимок состояния для отслеживания изменений.
    struct Snapshot: Equatable {
        // MARK: - Свойства

        let name: String
        let startDate: Date
        let endDate: Date
        let baseCurrency: Currency

        // MARK: - Инициализация

        init(viewModel: TripEditViewModel) {
            self.init(
                name: viewModel.name,
                startDate: viewModel.startDate,
                endDate: viewModel.endDate,
                baseCurrency: viewModel.baseCurrency
            )
        }
        
        init(name: String, startDate: Date, endDate: Date, baseCurrency: Currency) {
            self.name = name.trimmed
            self.startDate = startDate
            self.endDate = endDate
            self.baseCurrency = baseCurrency
        }
    }
}
