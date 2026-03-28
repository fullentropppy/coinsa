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
        
    // MARK: - Computed properties
    
    private var repository: TripRepository {
        TripRepository(context: context)
    }

    // MARK: - Initialization
    
    init(trip: Trip? = nil) {
        _viewModel = State(initialValue: TripEditViewModel(trip: trip))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                mainDataSection
                actionsSection
            }
            .navigationTitle(viewModel.navigationTitle)
            .toolbarTitleDisplayMode(.inline)
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
                message: "trip.delete.message",
                onConfirm: {
                    confirmDelete()
                    dismiss()
                },
                onCancel: {
                    cancelDelete()
                }
            )
        }
    }

    // MARK: - Components
    
    private var mainDataSection: some View {
        Section {
            TextField("trip.name", text: $viewModel.name)
            DatePicker(
                "trip.startDate",
                selection: $viewModel.startDate,
                displayedComponents: .date
            )
            DatePicker(
                "trip.endDate",
                selection: $viewModel.endDate,
                in: viewModel.startDate...,
                displayedComponents: .date
            )
        }
    }
    
    private var actionsSection: some View {
        Section {
            if viewModel.isEditing {
                Button("trip.editing.delete", role: .destructive) {
                    requestDelete()
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            ButtonView.close {
                handleClose()
            }
        }

        ToolbarItemGroup(placement: .topBarTrailing) {
            ButtonView.save {
                viewModel.save(using: repository)
                dismiss()
            }
            .disabled(!viewModel.canSave)
        }
    }
    
    // MARK: - Actions

    private func requestDelete() {
        guard let trip = viewModel.tripToEdit else { return }
        deletionHandler.request(for: [trip])
    }

    private func handleClose() {
        if viewModel.hasChanges {
            isShowingDiscardAlert = true
        } else {
            dismiss()
        }
    }

    private func confirmDelete() {
        deletionHandler.confirm { repository.delete($0) }
        dismiss()
    }

    private func cancelDelete() {
        deletionHandler.cancel()
    }
}

// MARK: - Previews

private extension TripEditView {
    static func preview(
        withTrip: Bool,
        locale: Locale,
        colorScheme: ColorScheme
    ) -> some View {
        var trip: Trip? = nil
        
        if withTrip {
            let builder = PreviewBuilder.builder().withBudgets(false).withExpenses(false)
            let data = builder.buildData()
            trip = builder.getTrip(from: data)
        }

        return TripEditView(trip: trip)
            .environment(\.locale, locale)
            .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    TripEditView.preview(withTrip: true, locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    TripEditView.preview(withTrip: true, locale: PreviewLocale.en.locale, colorScheme: .dark)
}

#Preview("New Trip. Light - RU") {
    TripEditView.preview(withTrip: false, locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("New Trip. Dark - EN") {
    TripEditView.preview(withTrip: false, locale: PreviewLocale.en.locale, colorScheme: .dark)
}
