//
//  LocationEditorContainerView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

import SwiftUI
import SwiftData

/// Контейнер редактора локации, управляющий состоянием интерфейса и действиями формы.
struct LocationEditorContainerView: View {
    // MARK: - Окружение

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    // MARK: - Состояние

    @State private var viewModel: LocationEditViewModel
    @State private var deletionHandler = DeletionHandler<Location>()
    @State private var inputCurrency: CurrencyContext = .home
    @State private var isShowingDiscardAlert = false
    @State private var validationNotice: FormValidationNotice?
    @State private var storageErrorMessage: LocalizedStringResource?
    @State private var isSaving = false
    @FocusState private var focusedField: NumericEditField?
    @FocusState private var isNameFocused: Bool

    // MARK: - Зависимости

    private let onDelete: (() -> Void)?

    // MARK: - Инфраструктура

    private var repository: LocationRepository {
        LocationRepository(context: context)
    }

    // MARK: - Инициализация

    /// Создает контейнер подготовленного черновика локации.
    /// - Parameters:
    ///   - initialViewModel: Общий черновик с доступной родительской поездкой.
    ///   - onDelete: Действие после успешного удаления.
    init(initialViewModel: LocationEditViewModel, onDelete: (() -> Void)? = nil) {
        _viewModel = State(initialValue: initialViewModel)
        self.onDelete = onDelete
    }

    // MARK: - Тело View

    var body: some View {
        NavigationStack {
            locationEditForm
                .disabled(isSaving)
                .navigationTitle(viewModel.navigationTitle)
                .navigationSubtitle(viewModel.trip.screenContextSubtitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbarContent
                }
                .interactiveDismissDisabled(true)
                .scrollDismissesKeyboard(.interactively)
                .keyboardInputBar(
                    isPresented: focusedField != nil || isNameFocused,
                    onDismiss: dismissKeyboard
                )
                .formValidationBanner($validationNotice)
                .notificationAlert(
                    isPresented: rateErrorBinding,
                    title: .exchangeRateLoadingErrorTitle,
                    message: .exchangeRateLoadingErrorMessage(
                        errorDescription: viewModel.rateLoadingError?.errorDescription
                        ?? String(localized: .errorUnknown)
                    ),
                    isError: true
                )
                .notificationAlert(
                    isPresented: storageErrorBinding,
                    title: .locationStorageErrorTitle,
                    message: storageErrorMessage ?? .errorUnknown,
                    isError: true
                )
                .discardConfirmationAlert(
                    isPresented: $isShowingDiscardAlert,
                    onConfirm: { dismiss() }
                )
                .deleteConfirmationAlert(
                    isPresented: $deletionHandler.isShowingDeleteConfirmation,
                    title: .locationDeleteTitle,
                    message: .locationDeleteMessage,
                    onConfirm: { confirmDelete() },
                    onCancel: { cancelDelete() }
                )
                .task {
                    viewModel.loadInitialRateIfNeeded()
                }
        }
    }

    // MARK: - Основной контент

    private var locationEditForm: some View {
        LocationFormView(
            viewModel: viewModel,
            inputCurrency: inputCurrency,
            focusedField: $focusedField,
            isNameFocused: $isNameFocused,
            onSwitchInputCurrency: switchInputCurrency,
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

    private var rateErrorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.rateLoadingError != nil },
            set: { shows in
                if !shows {
                    viewModel.rateLoadingError = nil
                }
            }
        )
    }

    // MARK: - Действия

    private func switchInputCurrency() {
        focusedField = nil
        switch inputCurrency {
        case .home: inputCurrency = .location
        case .location, .expense: inputCurrency = .home
        }
    }

    private func dismissKeyboard() {
        focusedField = nil
        isNameFocused = false
    }

    private func handleSave() {
        guard !isSaving else { return }
        isSaving = true
        dismissKeyboard()

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
                if let repositoryError = error as? LocationRepositoryError,
                   repositoryError == .tripUnavailable {
                    storageErrorMessage = .locationEditorUnavailableMessage
                } else {
                    storageErrorMessage = .locationStorageSaveErrorMessage
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
        if let location = viewModel.location {
            deletionHandler.request(for: [location])
        }
    }

    private func confirmDelete() {
        do {
            try repository.delete(deletionHandler.itemsPendingDeletion)
            deletionHandler.cancel()
            onDelete?()
            dismiss()
        } catch {
            storageErrorMessage = .locationStorageDeleteErrorMessage
        }
    }

    private func cancelDelete() {
        deletionHandler.cancel()
    }
}

// MARK: - Превью

#Preview("Editing") {
    @Previewable @State var preview = LocationFormPreviewData(isEditing: true)

    if let viewModel = preview.viewModel {
        LocationEditorContainerView(initialViewModel: viewModel)
            .modelContainer(preview.container)
            .environment(preview.settingsStore)
    }
}

#Preview("Creating") {
    @Previewable @State var preview = LocationFormPreviewData(isEditing: false)

    if let viewModel = preview.viewModel {
        LocationEditorContainerView(initialViewModel: viewModel)
            .modelContainer(preview.container)
            .environment(preview.settingsStore)
    }
}
