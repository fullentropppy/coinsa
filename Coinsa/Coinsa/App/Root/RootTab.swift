//
//  RootTab.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.04.2026.
//

import Foundation

/// Вкладки главного таб-бара приложения.
enum RootTab: Hashable {
    // MARK: - Значения
    
    case today
    case trips
    case settings
    
    // MARK: - Свойства
    
    var icon: String {
        switch self {
        case .today: "\(Date().day).calendar"
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
