//
//  TripEditorContainerView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

import SwiftUI
import SwiftData

/// Контейнер редактора поездки, управляющий состоянием интерфейса и действиями формы.
struct TripEditorContainerView: View {
    // MARK: - Окружение
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Состояние
    
    @State private var viewModel: TripEditViewModel
    @State private var deletionHandler = DeletionHandler<Trip>()
    @State private var isShowingDiscardAlert = false
    @State private var validationNotice: FormValidationNotice?
    @State private var storageErrorMessage: LocalizedStringResource?
    @State private var isSaving = false

    @FocusState private var isNameFocused: Bool
    
    // MARK: - Зависимости
    
    private let onDelete: (() -> Void)?
    
    // MARK: - Инфраструктура
    
    private var repository: TripRepository {
        TripRepository(context: context)
    }
    
    // MARK: - Инициализация

    /// Создает контейнер подготовленного черновика поездки.
    /// - Parameters:
    ///   - initialViewModel: Общий черновик поездки.
    ///   - onDelete: Действие после успешного удаления.
    init(initialViewModel: TripEditViewModel, onDelete: (() -> Void)? = nil) {
        _viewModel = State(initialValue: initialViewModel)
        self.onDelete = onDelete
    }

    // MARK: - Тело View

    var body: some View {
        NavigationStack {
            tripEditForm
                .disabled(isSaving)
                .navigationTitle(viewModel.navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbarContent
                }
                .interactiveDismissDisabled(true)
                .scrollDismissesKeyboard(.interactively)
                .keyboardInputBar(isPresented: isNameFocused) {
                    isNameFocused = false
                }
                .formValidationBanner($validationNotice)
                .notificationAlert(
                    isPresented: storageErrorBinding,
                    title: .tripStorageErrorTitle,
                    message: storageErrorMessage ?? .errorUnknownMessage,
                    isError: true
                )
                .discardConfirmationAlert(
                    isPresented: $isShowingDiscardAlert,
                    onConfirm: { dismiss() }
                )
                .deleteConfirmationAlert(
                    isPresented: $deletionHandler.isShowingDeleteConfirmation,
                    title: .tripDeleteTitle,
                    message: .tripDeleteMessage,
                    onConfirm: { confirmDelete() },
                    onCancel: { cancelDelete() }
                )
        }
    }

    // MARK: - Основной контент

    private var tripEditForm: some View {
        TripFormView(
            viewModel: viewModel,
            isNameFocused: $isNameFocused,
            onDelete: requestDelete
        )
    }

    // MARK: - Тулбар
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            ToolbarButton.close {
                handleClose()
            }
            .disabled(isSaving)
        }
        
        ToolbarItemGroup(placement: .topBarTrailing) {
            ToolbarButton.ok {
                handleSave()
            }
            .disabled(isSaving)
        }
    }
    
    // MARK: - Биндинги
    
    private var storageErrorBinding: Binding<Bool> {
        Binding(
            get: { storageErrorMessage != nil },
            set: { if !$0 { storageErrorMessage = nil } }
        )
    }

    // MARK: - Действия
    
    private func handleSave() {
        guard !isSaving else { return }
        isSaving = true
        isNameFocused = false

        DispatchQueue.main.asyncAfter(deadline: .now() + ViewLayout.Editor.saveAfterKeyboardDismissDelay) {
            defer { isSaving = false }

            if let validationMessage = viewModel.validationMessage {
                validationNotice = FormValidationNotice(message: validationMessage)
                return
            }

            do {
                try viewModel.save(using: repository)
                dismiss()
            } catch {
                if let repositoryError = error as? TripRepositoryError {
                    switch repositoryError {
                    case .tripUnavailable:
                        storageErrorMessage = .tripEditorUnavailableMessage
                    case .homeCurrencyLocked:
                        if let trip = viewModel.trip, !trip.isDeleted, trip.modelContext === context {
                            viewModel.homeCurrency = trip.homeCurrency
                        }
                        storageErrorMessage = .tripStorageErrorHomeCurrencyLockedMessage
                    }
                } else {
                    storageErrorMessage = .tripStorageErrorSaveMessage
                }
            }
        }
    }

    private func handleClose() {
        if viewModel.hasChanges {
            isShowingDiscardAlert = true
        } else {
            dismiss()
        }
    }
    
    private func requestDelete() {
        if let trip = viewModel.trip {
            deletionHandler.request(for: [trip])
        }
        
    }
    
    private func confirmDelete() {
        do {
            try repository.delete(deletionHandler.itemsPendingDeletion)
            deletionHandler.cancel()
            onDelete?()
            dismiss()
        } catch {
            storageErrorMessage = (error as? TripRepositoryError) == .tripUnavailable
                ? .tripEditorUnavailableMessage
                : .tripStorageErrorDeleteMessage
        }
    }
    
    private func cancelDelete() {
        deletionHandler.cancel()
    }
}

// MARK: - Превью

#Preview("Editing") {
    @Previewable @State var preview = TripPreviewData()

    if let viewModel = preview.viewModel {
        TripEditorContainerView(initialViewModel: viewModel)
            .modelContainer(preview.container)
            .environment(preview.settingsStore)
    }
}

#Preview("Creating") {
    @Previewable @State var preview = TripPreviewData(isEditing: false)

    if let viewModel = preview.viewModel {
        TripEditorContainerView(initialViewModel: viewModel)
            .modelContainer(preview.container)
            .environment(preview.settingsStore)
    }
}
