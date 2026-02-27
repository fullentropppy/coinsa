//
//  TripEditView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import SwiftUI

struct TripEditView: View {
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var viewModel: TripViewModel
    
    private var store: TripStore {
        TripStore(context: context)
    }

    init(trip: Trip? = nil) {
        _viewModel = State(initialValue: TripViewModel(trip: trip))
    }
    
    // MARK: - Body
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        NavigationStack {
            Form {
                TextField("trip.editing.name.title", text: $viewModel.name)
                DatePicker("trip.editing.startDate.title", selection: $viewModel.startDate, displayedComponents: .date)
                DatePicker("trip.editing.endDate.title", selection: $viewModel.endDate, displayedComponents: .date)
            }
            .navigationTitle(viewModel.title)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("common.cancel") { dismiss() }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(viewModel.isEditing ? "common.done" : "common.save") {
                        viewModel.save(using: store)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    TripEditView()
}
