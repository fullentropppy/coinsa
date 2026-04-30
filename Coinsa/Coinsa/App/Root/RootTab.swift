//
//  RootTab.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.04.2026.
//

import Foundation

enum RootTab: Hashable {
    // MARK: - Значения
    
    case today
    case trips
    case settings
    
    // MARK: - Свойства
    
    private var todayIcon: String {
        "\(Date().day).calendar"
    }
    
    var icon: String {
        switch self {
        case .today: todayIcon
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
