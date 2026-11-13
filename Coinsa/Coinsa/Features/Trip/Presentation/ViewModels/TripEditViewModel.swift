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
        validationMessage == nil
    }

    var validationMessage: LocalizedStringResource? {
        if name.isBlank {
            .validationTripNameRequired
        } else {
            nil
        }
    }

    var hasLocations: Bool {
        trip?.hasLocations ?? false
    }
    
    var totalDays: Int {
        endDate.days(from: startDate) + 1
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
    var homeCurrency: Currency
    
    // MARK: - Инициализация

    /// Создает ViewModel для новой поездки.
    /// - Parameter homeCurrency: Домашняя валюта по умолчанию.
    convenience init(forCreateWith homeCurrency: Currency) {
        self.init(
            trip: nil,
            name: "",
            startDate: PlainDate.today.storedDate,
            endDate: PlainDate.today.storedDate,
            homeCurrency: homeCurrency
        )
    }
    
    /// Создает ViewModel для редактирования существующей поездки.
    /// - Parameter trip: Редактируемая поездка.
    convenience init(forEdit trip: Trip) {
        self.init(
            trip: trip,
            name: trip.name,
            startDate: trip.startPlainDate.storedDate,
            endDate: trip.endPlainDate.storedDate,
            homeCurrency: trip.homeCurrency
        )
    }

    /// Создает черновик поездки и исходный снимок для определения изменений.
    private init(
        trip: Trip?,
        name: String,
        startDate: Date,
        endDate: Date,
        homeCurrency: Currency
    ) {
        self.trip = trip
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.homeCurrency = homeCurrency
        
        self.initialSnapshot = Snapshot(
            name: name,
            startDate: startDate,
            endDate: endDate,
            homeCurrency: homeCurrency
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
                homeCurrency: homeCurrency
            )
        } else {
            repository.add(
                name: name,
                startDate: startDate,
                endDate: endDate,
                homeCurrency: homeCurrency
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
        let homeCurrency: Currency

        // MARK: - Инициализация

        /// Фиксирует текущее состояние редактора поездки для сравнения изменений.
        init(viewModel: TripEditViewModel) {
            self.init(
                name: viewModel.name,
                startDate: viewModel.startDate,
                endDate: viewModel.endDate,
                homeCurrency: viewModel.homeCurrency
            )
        }
        
        /// Создает снимок поездки, удаляя крайние пробелы из названия.
        init(name: String, startDate: Date, endDate: Date, homeCurrency: Currency) {
            self.name = name.trimmed
            self.startDate = startDate
            self.endDate = endDate
            self.homeCurrency = homeCurrency
        }
    }
}
