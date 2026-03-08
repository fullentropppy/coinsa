//
//  UpcomingTripView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI
import SwiftData

struct UpcomingTripView: View {
    // MARK: - Stored Properties

    @Environment(AppSettingsStore.self) private var settingsStore

    @State private var isShowingTripAdd = false

    let trip: Trip?

    // MARK: - Body

    var body: some View {
        VStack(spacing: 24) {
            if let trip {
                VStack(alignment: .leading, spacing: 12) {
                    Text("now.upcoming.title")
                        .font(.headline)

                    NavigationLink {
                        TripDetailView(trip: trip)
                    } label: {
                        TripRowView(trip: trip)
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                EmptyStateView(
                    imageName: "calendar",
                    title: "now.upcoming.empty.title",
                    description: "now.upcoming.empty.description",
                    buttonLabel: "trip.list.addTrip",
                    onAddAction: { isShowingTripAdd = true }
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .sheet(isPresented: $isShowingTripAdd) {
            TripEditView(trip: nil, baseCurrencyCode: settingsStore.baseCurrencyCode)
        }
    }
}

// MARK: - Previews

#Preview("Light - RU") {
    let builder = PreviewBuilder.builder()
    let container = builder.buildContainer()
    let trip = builder.fetchTrip(from: container)
    let store = AppSettingsStore(context: container.mainContext)
    store.baseCurrencyCode = PreviewCurrency.baseCurrencyCode

    return UpcomingTripView(trip: trip)
        .environment(store)
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
}
