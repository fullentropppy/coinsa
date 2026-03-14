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
        messageKey: "trip.deletionConfirmation.message.single"
    )
        
    // MARK: - Computed properties
    
    private var repository: TripRepository {
        TripRepository(context: context)
    }

    // MARK: - Initialization
    
    init(trip: Trip? = nil) {
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
            ButtonView.close {
                dismiss()
            }
        }

        ToolbarItemGroup(placement: .topBarTrailing) {
            ButtonView.save {
                viewModel.save(using: repository)
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
        deletionHandler.confirmDelete { repository.delete($0) }
        dismiss()
    }

    private func cancelDelete() {
        deletionHandler.cancelDelete()
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
