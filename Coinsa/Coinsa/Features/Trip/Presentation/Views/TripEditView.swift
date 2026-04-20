//
//  TripEditView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import SwiftUI
import SwiftData

struct TripEditView: View {
    // MARK: - Окружение
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    // MARK: - Состояние
    
    @State private var viewModel: TripEditViewModel
    @State private var deletionHandler = DeletionHandler<Trip>()
    @State private var isShowingDiscardAlert = false
    
    // MARK: - Зависимости
    
    private let onDelete: (() -> Void)?
        
    // MARK: - Инфраструктура
    
    private var repository: TripRepository {
        TripRepository(context: context)
    }

    // MARK: - Инициализация
    
    init(_ trip: Trip? = nil, onDelete: (() -> Void)? = nil) {
        _viewModel = State(initialValue: TripEditViewModel(trip: trip))
        self.onDelete = onDelete
    }
    
    // MARK: - Тело View
    
    var body: some View {
        NavigationStack {
            tripEditForm
                .navigationTitle(viewModel.navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbarContent
                }
                .interactiveDismissDisabled(true)
                .scrollDismissesKeyboard(.interactively)
                .discardConfirmationAlert(
                    isPresented: $isShowingDiscardAlert,
                    onConfirm: { dismiss() }
                )
                .deleteConfirmationAlert(
                    isPresented: $deletionHandler.isShowingDeleteConfirmation,
                    title: .tripDeleteTitle,
                    message: .tripDeleteMessage,
                    onConfirm: { confirmDelete() },
                    onCancel: { cancelDelete()
                    }
                )
        }
    }

    // MARK: - Основной контент
    
    private var tripEditForm: some View {
        Form {
            mainDataSection
            actionsSection
        }
    }
    
    // MARK: - Секции
    
    private var mainDataSection: some View {
        Section {
            TextField(.tripName, text: $viewModel.name)
            DatePicker(
                .tripStartDate,
                selection: Binding(
                    get: { viewModel.startDate },
                    set: { viewModel.startDate = $0 }
                ),
                displayedComponents: .date
            )
            DatePicker(
                .tripEndDate,
                selection: Binding(
                    get: { viewModel.endDate },
                    set: { viewModel.endDate = $0 }
                ),
                in: viewModel.startDate...,
                displayedComponents: .date
            )
        }
    }
    
    @ViewBuilder
    private var actionsSection: some View {
        if viewModel.isEditing {
            Section {
                Button(.tripDelete, role: .destructive) {
                    requestDelete()
                }
            }
        }
    }
    
    // MARK: - Тулбар
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            ToolbarButton.close {
                handleClose()
            }
        }

        ToolbarItemGroup(placement: .topBarTrailing) {
            ToolbarButton.ok {
                viewModel.save(using: repository)
                dismiss()
            }
            .disabled(!viewModel.canSave)
        }
    }
    
    // MARK: - Действия

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
        deletionHandler.confirm { repository.delete($0) }
        dismiss()
        onDelete?()
    }

    private func cancelDelete() {
        deletionHandler.cancel()
    }
}

// MARK: - Превью

private extension TripEditView {
    static func makePreview(
        locale: Locale,
        colorScheme: ColorScheme,
        withNewTrip: Bool = false
    ) -> some View {
        var trip: Trip? = nil
        
        if !withNewTrip {
            let builder = PreviewBuilder.builder().withLocations(false)
            let data = builder.buildData()
            trip = builder.getTrip(from: data)
        }

        return TripEditView(trip)
            .environment(\.locale, locale)
            .preferredColorScheme(colorScheme)
    }
}

#Preview("Edit. Light - RU") {
    TripEditView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Edit. Dark - EN") {
    TripEditView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}

#Preview("Create. Light - RU") {
    TripEditView.makePreview(locale: PreviewLocale.ru, colorScheme: .light, withNewTrip: true)
}

#Preview("Create. Dark - EN") {
    TripEditView.makePreview(locale: PreviewLocale.en, colorScheme: .dark, withNewTrip: true)
}
