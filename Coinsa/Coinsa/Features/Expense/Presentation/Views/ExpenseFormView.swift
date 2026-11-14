//
//  ExpenseFormView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 14.11.2026.
//

import SwiftUI
import SwiftData

/// Форма редактирования траты с доступной локацией и отдельным черновиком.
struct ExpenseFormView: View {
    // MARK: - Окружение

    @Environment(\.modelContext) private var context
    @Environment(AppSettingsStore.self) private var settingsStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.haptics) private var haptics

    // MARK: - Состояние

    @State private var viewModel: ExpenseEditViewModel
    @State private var deletionHandler = DeletionHandler<Expense>()
    @State private var currentLocationProvider = CurrentLocationProvider()
    @State private var currencyPairSide: CurrencyPairSide
    @State private var isShowingGeolocationError = false
    @State private var isShowingDiscardAlert = false
    @State private var isShowingLocationMap = false
    @State private var validationNotice: FormValidationNotice?
    @State private var storageErrorMessage: LocalizedStringResource?
    @State private var isSaving = false
    @State private var isResolvingLocation = false
    @State private var locationTask: Task<Void, Never>?

    @FocusState private var focusedField: NumericEditField?
    @FocusState private var isCommentFocused: Bool

    // MARK: - Зависимости

    private let onDelete: (() -> Void)?

    // MARK: - Инфраструктура

    private var repository: ExpenseRepository {
        ExpenseRepository(context: context)
    }

    // MARK: - Инициализация

    /// Создает форму подготовленного черновика с начальной стороной валютной пары.
    /// - Parameters:
    ///   - initialViewModel: Черновик с доступной родительской локацией.
    ///   - onDelete: Действие после успешного удаления.
    init(initialViewModel: ExpenseEditViewModel, onDelete: (() -> Void)? = nil) {
        _viewModel = State(initialValue: initialViewModel)
        _currencyPairSide = State(
            initialValue: initialViewModel.homeCurrency == initialViewModel.expenseCurrency ? .base : .quote
        )
        self.onDelete = onDelete
    }

    // MARK: - Тело View

    var body: some View {
        NavigationStack {
            expenseEditForm
                .disabled(isSaving)
                .navigationTitle(viewModel.navigationTitle)
                .navigationSubtitle(viewModel.location.screenContextSubtitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbarContent
                }
                .interactiveDismissDisabled(true)
                .scrollDismissesKeyboard(.interactively)
                .keyboardInputBar(
                    isPresented: focusedField != nil || isCommentFocused,
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
                    isPresented: $isShowingGeolocationError,
                    title: .expenseCoordinateErrorTitle,
                    message: .expenseCoordinateErrorMessage,
                    isError: true
                )
                .notificationAlert(
                    isPresented: storageErrorBinding,
                    title: .expenseStorageErrorTitle,
                    message: storageErrorMessage ?? .errorUnknown,
                    isError: true
                )
                .onDisappear {
                    locationTask?.cancel()
                }
                .discardConfirmationAlert(
                    isPresented: $isShowingDiscardAlert,
                    onConfirm: { dismiss() }
                )
                .deleteConfirmationAlert(
                    isPresented: $deletionHandler.isShowingDeleteConfirmation,
                    title: .expenseDeleteTitle,
                    message: .expenseDeleteMessage,
                    onConfirm: { confirmDelete() },
                    onCancel: { cancelDelete() }
                )
                .task {
                    if settingsStore.fetchExpenseExchangeRateOnline {
                        viewModel.loadInitialRateIfNeeded()
                    }
                    if settingsStore.detectPlaceOfExpense {
                        await resolveCurrentLocationIfNeeded()
                    }
                }
                .fullScreenCover(isPresented: $isShowingLocationMap) {
                    placeOfExpenseEditor
                }
        }
    }

    // MARK: - Основной контент

    private var expenseEditForm: some View {
        ExpenseFormFields(
            viewModel: viewModel,
            currencyPairSide: currencyPairSide,
            focusedField: $focusedField,
            isCommentFocused: $isCommentFocused,
            isResolvingLocation: isResolvingLocation,
            onSwitchInputCurrency: switchInputCurrency,
            onLocate: requestCurrentLocation,
            onShowMap: { isShowingLocationMap = true },
            onDelete: requestDelete
        )
    }

    // MARK: - Карта

    private var placeOfExpenseEditor: some View {
        FullScreenMapView(
            coordinate: Binding(
                get: { viewModel.coordinate },
                set: { viewModel.updateCoordinate($0) }
            ),
            title: viewModel.subcategory.localizedResource,
            markerTitle: .expensePlaceOfExpense,
            errorTitle: .expenseCoordinateErrorTitle,
            errorMessage: .expenseCoordinateErrorMessage
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
        switch currencyPairSide {
        case .base:
            currencyPairSide = .quote
        case .quote:
            currencyPairSide = .base
        }
    }

    private func dismissKeyboard() {
        haptics.trigger(.tap)
        focusedField = nil
        isCommentFocused = false
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
                if let repositoryError = error as? ExpenseRepositoryError,
                   repositoryError == .locationUnavailable {
                    storageErrorMessage = .expenseEditorUnavailableMessage
                } else {
                    storageErrorMessage = .expenseStorageSaveErrorMessage
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
        if let expense = viewModel.expense {
            deletionHandler.request(for: [expense])
        }
    }

    private func confirmDelete() {
        do {
            try repository.delete(deletionHandler.itemsPendingDeletion)
            deletionHandler.cancel()
            onDelete?()
            dismiss()
        } catch {
            storageErrorMessage = .expenseStorageDeleteErrorMessage
        }
    }

    private func cancelDelete() {
        deletionHandler.cancel()
    }

    private func requestCurrentLocation() {
        guard locationTask == nil else { return }
        haptics.trigger(.tap)
        locationTask = Task {
            await resolveCurrentLocation()
            locationTask = nil
        }
    }

    private func resolveCurrentLocationIfNeeded() async {
        guard !viewModel.isEdit, viewModel.coordinate == nil else { return }
        await resolveCurrentLocation(automatically: true)
    }

    private func resolveCurrentLocation(automatically: Bool = false) async {
        guard !isResolvingLocation else { return }
        isResolvingLocation = true
        let previousCoordinate = viewModel.coordinate
        defer { isResolvingLocation = false }

        do {
            let location = try await currentLocationProvider.requestCurrentLocation()
            try Task.checkCancellation()
            guard viewModel.coordinate == previousCoordinate else { return }
            if automatically {
                viewModel.applyResolvedCurrentLocation(location)
            } else {
                viewModel.updateCoordinate(Coordinate(location))
            }
        } catch is CancellationError {
            return
        } catch {
            isShowingGeolocationError = true
        }
    }
}

// MARK: - Превью

#Preview("Editing") {
    @Previewable @State var preview = ExpenseFormPreviewData(isEditing: true)

    if let viewModel = preview.viewModel {
        ExpenseFormView(initialViewModel: viewModel)
            .modelContainer(preview.container)
            .environment(preview.settingsStore)
    }
}

#Preview("Creating") {
    @Previewable @State var preview = ExpenseFormPreviewData(isEditing: false)

    if let viewModel = preview.viewModel {
        ExpenseFormView(initialViewModel: viewModel)
            .modelContainer(preview.container)
            .environment(preview.settingsStore)
    }
}
