//
//  ExpenseEditView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.03.2026.
//

import SwiftUI

/// Экран создания/редактирования траты.
struct ExpenseEditView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: ExpenseEditViewModel?
    private let onDelete: (() -> Void)?

    /// Создает экран новой траты с выбранными параметрами.
    /// - Parameters:
    ///   - location: Локация траты.
    ///   - preselectedCategory: Предустановленная категория.
    ///   - preselectedSubcategory: Подкатегория, определяющая категорию.
    ///   - preselectedPaymentMethod: Предустановленный способ оплаты.
    init(
        forCreateWith location: Location,
        preselectedCategory: ExpenseCategory? = nil,
        preselectedSubcategory: ExpenseSubcategory? = nil,
        preselectedPaymentMethod: PaymentMethod? = nil
    ) {
        _viewModel = State(initialValue: ExpenseEditViewModel(
            forCreateWith: location,
            preselectedCategory: preselectedCategory,
            preselectedSubcategory: preselectedSubcategory,
            preselectedPaymentMethod: preselectedPaymentMethod
        ))
        onDelete = nil
    }

    /// Создает редактор или сообщает о недоступности родительской локации.
    /// - Parameters:
    ///   - expense: Редактируемая трата.
    ///   - onDelete: Действие после успешного удаления.
    init(forEdit expense: Expense, onDelete: (() -> Void)? = nil) {
        _viewModel = State(initialValue: ExpenseEditViewModel(forEdit: expense))
        self.onDelete = onDelete
    }

    var body: some View {
        if let viewModel {
            ExpenseFormView(initialViewModel: viewModel, onDelete: onDelete)
        } else {
            NavigationStack {
                ContentUnavailableView {
                    Label {
                        Text(.expenseEditorUnavailableTitle)
                    } icon: {
                        Image(systemName: "exclamationmark.triangle")
                    }
                } description: {
                    Text(.expenseEditorUnavailableMessage)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        ToolbarButton.close { dismiss() }
                    }
                }
            }
        }
    }
}

// MARK: - Превью

#Preview("Editing") {
    ExpenseEditView(forEdit: PreviewGenerator.makeExampleExpense())
        .environment(AppSettingsStore())
}

#Preview("Creating") {
    ExpenseEditView(forCreateWith: PreviewGenerator.makeExampleLocation())
        .environment(AppSettingsStore())
}
