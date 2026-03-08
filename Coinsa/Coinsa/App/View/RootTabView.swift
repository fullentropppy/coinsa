//
//  RootTabView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI

struct RootTabView: View {
    // MARK: - Stored Properties

    @State private var selection: RootTab = .now

    // MARK: - Body

    var body: some View {
        TabView(selection: $selection) {
            Tab("tab.now", systemImage: "clock", value: .now) {
                NowView()
            }

            Tab("tab.trips", systemImage: "suitcase", value: .trips) {
                TripListView()
            }

            Tab("tab.settings", systemImage: "gearshape", value: .settings) {
                SettingsView()
            }
        }
    }
}

// MARK: - Supporting Types

private enum RootTab: Hashable {
    case now
    case trips
    case settings
}
