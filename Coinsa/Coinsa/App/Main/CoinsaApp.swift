//
//  CoinsaApp.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 26.02.2026.
//

import SwiftUI
import SwiftData

@main
struct CoinsaApp: App {
    // MARK: - Свойства
    
    private let modelTypes: [any PersistentModel.Type] =
    [
        Trip.self,
        Location.self,
        Expense.self,
        AppSettings.self
    ]
    
    // MARK: - Тело View
    
    var body: some Scene {
        WindowGroup {
            RootContainerView()
        }
        .modelContainer(for: modelTypes)
    }
}
