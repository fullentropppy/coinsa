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
                TextField("trip.editing.name.title", text: $viewModel.name)
                DatePicker("trip.editing.startDate.title", selection: $viewModel.startDate, displayedComponents: .date)
                DatePicker("trip.editing.endDate.title", selection: $viewModel.endDate, displayedComponents: .date)
            }
            .navigationTitle(viewModel.navigationTitle)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("common.cancel") {
                        dismiss()
                    }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("common.save") {
                        viewModel.save(using: store)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Light - RU") {
    TripEditView(trip: PreviewDataFactory.builder().buildFirstTrip())
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
}

#Preview("Dark - EN") {
    TripEditView(trip: PreviewDataFactory.builder().buildFirstTrip())
        .environment(\.locale, Locale(identifier: "en"))
        .preferredColorScheme(.dark)
}

#Preview("Empty item") {
    TripEditView(trip: nil)
}
