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
    // MARK: - Stored properties
    
    private let modelTypes: [any PersistentModel.Type] =
    [
        Trip.self,
        Location.self,
        Budget.self,
        Expense.self
    ]
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            TripListView()
        }
        .modelContainer(for: modelTypes)
    }
}
