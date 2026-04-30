//
//  RootTabView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI

struct RootTabView: View {
    // MARK: - Свойства
    
    @State private var selection: RootTab = .today

    // MARK: - Тело View
    
    var body: some View {
        TabView(selection: $selection) {
            Tab(RootTab.today.title, systemImage: RootTab.today.icon, value: .today) {
                TodayView()
            }
            Tab(RootTab.trips.title, systemImage: RootTab.trips.icon, value: .trips) {
                TripListView()
            }
            Tab(RootTab.settings.title, systemImage: RootTab.settings.icon, value: .settings) {
                SettingsView()
            }
        }
    }
}

// MARK: - Внутренние типы

private enum RootTab: Hashable {
    // MARK: - Значения
    
    case today
    case trips
    case settings
    
    // MARK: - Свойства
    
    var icon: String {
        switch self {
        case .today: "calendar"
        case .trips: Trip.primaryIcon
        case .settings: "gearshape.fill"
        }
    }
    
    var title: LocalizedStringResource {
        switch self {
        case .today: .tabToday
        case .trips: .tabTrips
        case .settings: .tabSettings
        }
    }
}
