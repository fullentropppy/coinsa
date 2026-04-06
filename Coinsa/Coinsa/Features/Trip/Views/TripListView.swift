//
//  TripListView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import SwiftUI
import SwiftData

struct TripListView: View {
    // MARK: - Stored Properties
    
    @Environment(\.modelContext) private var context
    @Environment(AppSettingsStore.self) private var settingsStore
    
    @Query(sort: \Trip.startDate) private var trips: [Trip]

    @State private var deletionHandler = DeletionHandler<Trip>()
    @State private var isShowingTripEdit = false
    
    // MARK: - Computed Properties
    
    private var repository: TripRepository {
        TripRepository(context: context)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Group {
                if trips.isEmpty {
                    emptyTripListContent
                } else {
                    tripListContent
                }
            }
            .navigationTitle(.tripNavigationTitleList)
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isShowingTripEdit) {
                TripEditView(trip: nil)
            }
            .safeAreaInset(edge: .bottom) {
                if !trips.isEmpty {
                    PrimaryAddButtonView(isOnLeft: settingsStore.isAddButtonOnLeft) {
                        isShowingTripEdit = true
                    }
                }
            }
            .deleteConfirmationAlert(
                isPresented: $deletionHandler.isShowingDeleteConfirmation,
                title: .tripDeleteTitle,
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
    
    private var tripListContent: some View {
        List {
            ForEach(trips) { trip in
                NavigationLink {
                    TripDetailView(trip: trip)
                } label: {
                    TripRowView(trip: trip)
                }
            }
            .onDelete(perform: requestDelete)
        }
    }
    
    // MARK: - Components
    
    private var emptyTripListContent: some View {
        EmptyStateView(
            imageName: Trip.primaryIcon,
            title: .tripEmptyStateTitle,
            description: .tripEmptyStateDescription,
            buttonLabel: .tripAdd,
        ) {
            isShowingTripEdit = true
        }
    }
    
    // MARK: - Actions

    private func requestDelete(at offsets: IndexSet) {
        deletionHandler.request(for: offsets.map { trips[$0] })
    }

    private func confirmDelete() {
        deletionHandler.confirm { repository.delete($0) }
    }

    private func cancelDelete() {
        deletionHandler.cancel()
    }
}

// MARK: - Previews

private extension TripListView {
    static func makePreview(
        locale: Locale,
        colorScheme: ColorScheme,
        withTrips: Bool = true
    ) -> some View {
        let container = PreviewBuilder.builder()
            .withScenario(.all)
            .withTrips(withTrips)
            .withExpenses(false)
            .withBudgets(false)
            .buildContainer()
        
        let settingsStore = AppSettingsStore(context: container.mainContext)
        
        return TripListView()
            .modelContainer(container)
            .environment(settingsStore)
            .environment(\.locale, locale)
            .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    TripListView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    TripListView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}

#Preview("Empty. Light - RU") {
    TripListView.makePreview(locale: PreviewLocale.ru, colorScheme: .light, withTrips: false)
}

#Preview("Empty. Dark - EN") {
    TripListView.makePreview(locale: PreviewLocale.ru, colorScheme: .dark, withTrips: false)
}
