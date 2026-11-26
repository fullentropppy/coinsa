//
//  ExpenseDestinationViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.11.2026.
//

import Foundation
import Observation
import SwiftData

/// Выбирает назначение и готовит черновик копирования или переноса траты.
@MainActor
@Observable
final class ExpenseDestinationViewModel {
    // MARK: - Внутренние типы

    enum Mode {
        case copy
        case move
    }

    // MARK: - Зависимости

    let source: Expense
    let mode: Mode
    private let exchangeRateProvider: ExchangeRateProvider

    // MARK: - Состояние

    var draft: ExpenseEditViewModel?
    var errorMessage: LocalizedStringResource?
    private(set) var skipsLocationSelection = false

    // MARK: - Вычисляемые свойства

    var sourceTrip: Trip? {
        source.owningTrip
    }

    var sourceLocation: Location? {
        sourceTrip == nil ? nil : source.location
    }

    var navigationTitle: LocalizedStringResource {
        mode == .copy ? .expenseCopyNavigationTitle : .expenseMoveNavigationTitle
    }

    var destinationTitle: LocalizedStringResource {
        mode == .copy ? .expenseCopyDestinationTitle : .expenseMoveDestinationTitle
    }

    var hint: LocalizedStringResource {
        mode == .copy ? .expenseCopyHint : .expenseMoveHint
    }

    var errorTitle: LocalizedStringResource {
        mode == .copy ? .expenseStorageErrorTitle : .expenseMoveErrorTitle
    }

    var showsGeneralExpenses: Bool {
        mode == .copy || sourceLocation != nil
    }

    var groupedLocations: [(status: EventStatus, locations: [Location])] {
        guard let trip = sourceTrip else { return [] }
        return LocationGrouping.grouped((trip.locations ?? []).filter {
            (mode == .copy || $0 !== sourceLocation) && !$0.isDeleted && $0.trip === trip
        })
    }

    // MARK: - Инициализация

    /// Создает общий выбор назначения; копия без локаций сразу открывает черновик.
    /// - Parameters:
    ///   - source: Исходная трата текущей поездки.
    ///   - mode: Копирование или перенос с подтверждением в редакторе.
    ///   - exchangeRateProvider: Провайдер курсов черновика; nil использует Hexarate.
    init(source: Expense, mode: Mode = .copy, exchangeRateProvider: ExchangeRateProvider? = nil) {
        self.source = source
        self.mode = mode
        self.exchangeRateProvider = exchangeRateProvider ?? ExchangeRateProvider(service: HexarateService())
        if mode == .copy, let trip = sourceTrip, !trip.hasLocations, let context = source.modelContext {
            prepareGeneralDraft(in: context)
            skipsLocationSelection = draft != nil
        }
    }

    // MARK: - Действия

    func select(_ location: Location, in context: ModelContext) {
        guard draft == nil else { return }
        guard source.modelContext === context, sourceTrip?.modelContext === context,
              location.modelContext === context else {
            errorMessage = .expenseEditorUnavailableMessage
            return
        }
        draft = mode == .copy
            ? ExpenseEditViewModel(copying: source, to: location, exchangeRateProvider: exchangeRateProvider)
            : ExpenseEditViewModel(moving: source, to: location, exchangeRateProvider: exchangeRateProvider)
        if draft == nil { errorMessage = .expenseEditorUnavailableMessage }
    }

    func selectGeneralExpenses(in context: ModelContext) {
        guard draft == nil else { return }
        prepareGeneralDraft(in: context)
    }

    private func prepareGeneralDraft(in context: ModelContext) {
        guard source.modelContext === context, let trip = sourceTrip, trip.modelContext === context else {
            errorMessage = .expenseEditorUnavailableMessage
            return
        }
        draft = mode == .copy
            ? ExpenseEditViewModel(copying: source, to: trip, exchangeRateProvider: exchangeRateProvider)
            : ExpenseEditViewModel(moving: source, to: trip, exchangeRateProvider: exchangeRateProvider)
        if draft == nil { errorMessage = .expenseEditorUnavailableMessage }
    }
}
