//
//  RootTabView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI

struct RootTabView: View {
    // MARK: - Свойства
    
    @State private var selection: RootTab = .now

    // MARK: - Тело View
    
    var body: some View {
        TabView(selection: $selection) {
            Tab(.tabNow, systemImage: Location.primaryIcon, value: .now) {
                NowView()
            }
            Tab(.tabTrips, systemImage: Trip.primaryIcon, value: .trips) {
                TripListView()
            }
            Tab(.tabSettings, systemImage: AppSettings.primaryIcon, value: .settings) {
                SettingsView()
            }
        }
    }
}

// MARK: - Внутренние типы

private enum RootTab: Hashable {
    case now
    case trips
    case settings
}
