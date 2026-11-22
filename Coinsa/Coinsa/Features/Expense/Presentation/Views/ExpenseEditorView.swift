//
//  ExpenseEditorView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.03.2026.
//

import SwiftUI
import SwiftData

/// Экран создания/редактирования траты.
struct ExpenseEditorView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: ExpenseEditViewModel?
    private let onSave: (() -> Void)?
    private let onDelete: (() -> Void)?

    /// Создает вход редактора с уже подготовленным черновиком без повторной инициализации состояния.
    /// - Parameters:
    ///   - initialViewModel: Черновик создания или редактирования траты.
    ///   - onSave: Действие после успешного сохранения.
    ///   - onDelete: Действие после успешного удаления.
    init(
        initialViewModel: ExpenseEditViewModel,
        onSave: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        _viewModel = State(initialValue: initialViewModel)
        self.onSave = onSave
        self.onDelete = onDelete
    }

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
        onSave = nil
        onDelete = nil
    }

    /// Создает редактор или сообщает о недоступности родительской локации.
    /// - Parameters:
    ///   - expense: Редактируемая трата.
    ///   - onDelete: Действие после успешного удаления.
    init(forEdit expense: Expense, onDelete: (() -> Void)? = nil) {
        _viewModel = State(initialValue: ExpenseEditViewModel(forEdit: expense))
        onSave = nil
        self.onDelete = onDelete
    }

    var body: some View {
        if let viewModel {
            ExpenseEditorContainerView(initialViewModel: viewModel, onSave: onSave, onDelete: onDelete)
        } else {
            NavigationStack {
                ContentUnavailableView {
                    Label {
                        Text(.expenseEditorUnavailableTitle)
                    } icon: {
                        Image(systemName: AppSymbols.exclamationmarkTriangle)
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
    @Previewable @State var preview = ExpenseFormPreviewData(isEditing: true)

    if let viewModel = preview.viewModel {
        ExpenseEditorView(initialViewModel: viewModel)
            .modelContainer(preview.container)
            .environment(preview.settingsStore)
    }
}

#Preview("Creating") {
    @Previewable @State var preview = ExpenseFormPreviewData(isEditing: false)

    if let viewModel = preview.viewModel {
        ExpenseEditorView(initialViewModel: viewModel)
            .modelContainer(preview.container)
            .environment(preview.settingsStore)
    }
}
