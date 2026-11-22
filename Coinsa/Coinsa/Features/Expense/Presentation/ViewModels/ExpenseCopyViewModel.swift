//
//  ExpenseCopyViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 22.11.2026.
//

import Foundation
import Observation
import SwiftData

/// Выбор локации и подготовка единственного черновика копии траты.
@MainActor
@Observable
final class ExpenseCopyViewModel {
    // MARK: - Зависимости

    let source: Expense

    // MARK: - Состояние

    var draft: ExpenseEditViewModel?
    var errorMessage: LocalizedStringResource?
    private(set) var skipsLocationSelection = false

    // MARK: - Вычисляемые свойства

    var sourceLocation: Location? {
        guard !source.isDeleted, let location = source.location, !location.isDeleted,
              let trip = location.trip, !trip.isDeleted else { return nil }
        return location
    }

    var groupedLocations: [(status: EventStatus, locations: [Location])] {
        guard let sourceLocation, let trip = sourceLocation.trip else { return [] }
        return LocationGrouping.grouped((trip.locations ?? []).filter {
            $0 !== sourceLocation && !$0.isDeleted && $0.trip === trip
        })
    }

    // MARK: - Инициализация

    /// Создает состояние копирования и сразу готовит черновик, если доступна только исходная локация.
    /// - Parameter source: Исходная трата текущей поездки.
    init(source: Expense) {
        self.source = source

        if let location = sourceLocation, groupedLocations.isEmpty, let context = source.modelContext {
            select(location, in: context)
            skipsLocationSelection = draft != nil
        }
    }

    // MARK: - Действия

    func select(_ location: Location, in context: ModelContext) {
        guard source.modelContext === context, sourceLocation?.modelContext === context,
              location.modelContext === context,
              location.trip?.modelContext === context,
              let draft = ExpenseEditViewModel(copying: source, to: location) else {
            errorMessage = .expenseEditorUnavailableMessage
            return
        }
        self.draft = draft
    }
}
