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
    // MARK: - Stored Properties
    
    private let modelTypes: [any PersistentModel.Type] =
    [
        Trip.self,
        Location.self,
        Budget.self,
        Expense.self,
        AppSettings.self
    ]
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            RootContainerView()
        }
        .modelContainer(for: modelTypes)
    }
}
