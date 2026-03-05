//
//  TripEditView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import SwiftUI

struct TripEditView: View {
    // MARK: - Stored properties
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: TripViewModel
    @State private var deletionHandler = DeletionHandler<Trip>(
        singleMessageKey: "trip.deletionConfirmation.message.single",
        multipleMessageKey: "trip.deletionConfirmation.message.multiple"
    )
        
    // MARK: - Computed properties
    
    private var store: TripStore {
        TripStore(context: context)
    }

    // MARK: - Initialization
    
    init(trip: Trip? = nil, onSave: ((Trip) -> Void)? = nil) {
        _viewModel = State(initialValue: TripViewModel(trip: trip))
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
            .alert("trip.list.deletionConfirmation.title", isPresented: $deletionHandler.isShowingDeleteConfirmation) {
                Button("trip.list.deletionConfirmation.delete", role: .destructive) {
                    confirmDelete()
                    dismiss()
                }
                Button("common.cancel", role: .cancel) {
                    cancelDelete()
                }
            } message: {
                Text(deletionHandler.confirmationMessage)
            }
            .toolbar {
                toolbarContent
            }
        }
    }

    // MARK: - Components
    
    private var mainDataSection: some View {
        Section {
            TextField("trip.editing.name.title", text: $viewModel.name)
            DatePicker("trip.editing.startDate.title", selection: $viewModel.startDate, displayedComponents: .date)
            DatePicker("trip.editing.endDate.title", selection: $viewModel.endDate, displayedComponents: .date)
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
            Button("common.cancel", systemImage: "xmark") {
                dismiss()
            }
        }

        ToolbarItemGroup(placement: .topBarTrailing) {
            Button("common.save", systemImage: "checkmark") {
                viewModel.save(using: store)
                dismiss()
            }
        }
    }
    
    // MARK: - Actions

    private func requestDelete() {
        guard let trip = viewModel.tripToEdit else { return }
        deletionHandler.requestDelete(items: [trip])
    }

    private func confirmDelete() {
        deletionHandler.confirmDelete { store.delete($0) }
        dismiss()
    }

    private func cancelDelete() {
        deletionHandler.cancelDelete()
    }
}

// MARK: - Previews

private var previewTrip: Trip {
    let builder = PreviewBuilder.builder().withBudgets(false).withExpenses(false)
    let data = builder.buildData()
    return builder.getTrip(from: data)
}

#Preview("Light - RU") {
    TripEditView(trip: previewTrip)
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
}

#Preview("Dark - EN") {
    TripEditView(trip: previewTrip)
        .environment(\.locale, Locale(identifier: "en"))
        .preferredColorScheme(.dark)
}

#Preview("Empty item") {
    TripEditView(trip: nil)
}
