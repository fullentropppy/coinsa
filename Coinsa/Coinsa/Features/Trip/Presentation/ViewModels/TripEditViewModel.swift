//
//  TripEditViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation
import Observation
import SwiftData

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
        } else if !generalExpensesBudget.isFinite || generalExpensesBudget < 0 {
            .validationTripGeneralExpensesBudgetInvalid
        } else {
            nil
        }
    }

    var isHomeCurrencyLocked: Bool {
        guard let trip, !trip.isDeleted, trip.modelContext != nil else { return false }
        return !trip.canChangeHomeCurrency
    }
    
    var totalDays: Int {
        PlainDate(endDate).days(from: PlainDate(startDate)) + 1
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
    var generalExpensesBudget: Double
    
    // MARK: - Инициализация

    /// Создает ViewModel для новой поездки.
    /// - Parameter homeCurrency: Домашняя валюта по умолчанию.
    convenience init(forCreateWith homeCurrency: Currency) {
        self.init(
            trip: nil,
            name: "",
            startDate: PlainDate.today.storedDate,
            endDate: PlainDate.today.storedDate,
            homeCurrency: homeCurrency,
            generalExpensesBudget: 0
        )
    }
    
    /// Создает черновик существующей поездки или возвращает nil, если она недоступна в хранилище.
    /// - Parameter trip: Редактируемая поездка.
    convenience init?(forEdit trip: Trip) {
        guard !trip.isDeleted, trip.modelContext != nil else { return nil }

        self.init(
            trip: trip,
            name: trip.name,
            startDate: trip.startPlainDate.storedDate,
            endDate: trip.endPlainDate.storedDate,
            homeCurrency: trip.homeCurrency,
            generalExpensesBudget: trip.generalExpensesBudget
        )
    }

    /// Создает черновик поездки и исходный снимок для определения изменений.
    /// - Parameters:
    ///   - trip: Исходная поездка или nil при создании.
    ///   - name: Начальное название.
    ///   - startDate: Начальная календарная дата поездки.
    ///   - endDate: Конечная календарная дата поездки.
    ///   - homeCurrency: Домашняя валюта черновика.
    ///   - generalExpensesBudget: Начальный бюджет общих трат в домашней валюте.
    private init(
        trip: Trip?,
        name: String,
        startDate: Date,
        endDate: Date,
        homeCurrency: Currency,
        generalExpensesBudget: Double
    ) {
        self.trip = trip
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.homeCurrency = homeCurrency
        self.generalExpensesBudget = generalExpensesBudget
        
        self.initialSnapshot = Snapshot(
            name: name,
            startDate: startDate,
            endDate: endDate,
            homeCurrency: homeCurrency,
            generalExpensesBudget: generalExpensesBudget
        )
    }
    
    // MARK: - Операции с хранилищем

    func save(using repository: TripRepository) throws {
        if let trip {
            try repository.update(
                trip,
                name: name,
                startDate: startDate,
                endDate: endDate,
                homeCurrency: homeCurrency,
                generalExpensesBudget: generalExpensesBudget,
                expectedHomeCurrency: initialSnapshot.homeCurrency
            )
        } else {
            try repository.add(
                name: name,
                startDate: startDate,
                endDate: endDate,
                homeCurrency: homeCurrency,
                generalExpensesBudget: generalExpensesBudget
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
        let generalExpensesBudget: Double

        // MARK: - Инициализация

        /// Фиксирует текущее состояние редактора поездки для сравнения изменений.
        /// - Parameter viewModel: Черновик с бюджетом общих трат и остальными полями поездки.
        init(viewModel: TripEditViewModel) {
            self.init(
                name: viewModel.name,
                startDate: viewModel.startDate,
                endDate: viewModel.endDate,
                homeCurrency: viewModel.homeCurrency,
                generalExpensesBudget: viewModel.generalExpensesBudget
            )
        }
        
        /// Создает снимок поездки, удаляя крайние пробелы из названия.
        /// - Parameters:
        ///   - name: Название поездки.
        ///   - startDate: Начальная гражданская дата.
        ///   - endDate: Конечная гражданская дата.
        ///   - homeCurrency: Домашняя валюта.
        ///   - generalExpensesBudget: Бюджет общих трат.
        init(name: String, startDate: Date, endDate: Date, homeCurrency: Currency, generalExpensesBudget: Double) {
            self.name = name.trimmed
            self.startDate = startDate
            self.endDate = endDate
            self.homeCurrency = homeCurrency
            self.generalExpensesBudget = generalExpensesBudget
        }
    }
}
