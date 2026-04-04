//
//  TripEditView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import SwiftUI
import SwiftData

struct TripEditView: View {
    // MARK: - Stored properties
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: TripEditViewModel
    @State private var deletionHandler = DeletionHandler<Trip>()
    @State private var isShowingDiscardAlert = false
    
    private let onDelete: (() -> Void)?
        
    // MARK: - Computed Properties
    
    private var repository: TripRepository {
        TripRepository(context: context)
    }

    // MARK: - Initialization
    
    init(trip: Trip? = nil, onDelete: (() -> Void)? = nil) {
        _viewModel = State(initialValue: TripEditViewModel(trip: trip))
        self.onDelete = onDelete
    }
    
    // MARK: - Body
    
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
                    onConfirm: {
                        dismiss()
                    }
                )
                .deleteConfirmationAlert(
                    isPresented: $deletionHandler.isShowingDeleteConfirmation,
                    message: .tripDeleteMessage,
                    onConfirm: {
                        confirmDelete()
                    },
                    onCancel: {
                        cancelDelete()
                    }
                )
        }
    }

    // MARK: - Content
    
    private var tripEditForm: some View {
        Form {
            mainDataSection
            actionsSection
        }
    }
    
    // MARK: - Sections
    
    private var mainDataSection: some View {
        Section {
            TextField(.tripName, text: $viewModel.name)
            DatePicker(
                .tripStartDate,
                selection: Binding(
                    get: { viewModel.startDate },
                    set: { viewModel.startDate = $0.startOfDay }
                ),
                displayedComponents: .date
            )
            DatePicker(
                .tripEndDate,
                selection: Binding(
                    get: { viewModel.endDate },
                    set: { viewModel.endDate = $0.endOfDay }
                ),
                in: viewModel.startDate...,
                displayedComponents: .date
            )
        }
    }
    
    private var actionsSection: some View {
        Section {
            if viewModel.isEditing {
                Button(.tripDelete, role: .destructive) {
                    requestDelete()
                }
            }
        }
    }
    
    // MARK: - Components
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            ToolbarButtonView.close {
                handleClose()
            }
        }

        ToolbarItemGroup(placement: .topBarTrailing) {
            ToolbarButtonView.save {
                viewModel.save(using: repository)
                dismiss()
            }
            .disabled(!viewModel.canSave)
        }
    }
    
    // MARK: - Actions

    private func handleClose() {
        if viewModel.hasChanges {
            isShowingDiscardAlert = true
        } else {
            dismiss()
        }
    }
    
    private func requestDelete() {
        guard let trip = viewModel.trip else { return }
        deletionHandler.request(for: [trip])
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

// MARK: - Previews

private extension TripEditView {
    static func makePreview(
        withTrip: Bool,
        locale: Locale,
        colorScheme: ColorScheme
    ) -> some View {
        var trip: Trip? = nil
        
        if withTrip {
            let builder = PreviewBuilder.builder().withLocations(false)
            let data = builder.buildData()
            trip = builder.getTrip(from: data)
        }

        return TripEditView(trip: trip)
            .environment(\.locale, locale)
            .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    TripEditView.makePreview(withTrip: true, locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    TripEditView.makePreview(withTrip: true, locale: PreviewLocale.en.locale, colorScheme: .dark)
}

#Preview("New Trip. Light - RU") {
    TripEditView.makePreview(withTrip: false, locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("New Trip. Dark - EN") {
    TripEditView.makePreview(withTrip: false, locale: PreviewLocale.en.locale, colorScheme: .dark)
}
