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
    case converter
    case settings
    
    // MARK: - Свойства
    
    var icon: String {
        switch self {
        case .today: AppSymbols.calendarDay(Date().day)
        case .trips: Trip.primaryIcon
        case .converter: AppSymbols.arrowLeftArrowRightCircleFill
        case .settings: AppSymbols.gearshapeFill
        }
    }
    
    var title: LocalizedStringResource {
        switch self {
        case .today: .tabToday
        case .trips: .tabTrips
        case .converter: .tabConverter
        case .settings: .tabSettings
        }
    }
}
