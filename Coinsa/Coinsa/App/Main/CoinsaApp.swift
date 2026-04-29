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
        AppSettings.self,
        Trip.self,
        Location.self,
        Budget.self,
        Expense.self
    ]
    
    // MARK: - Тело View
    
    var body: some Scene {
        WindowGroup {
            RootContainerView()
        }
        .modelContainer(for: modelTypes)
    }
}
