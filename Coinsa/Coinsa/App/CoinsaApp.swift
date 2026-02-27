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
    // MARK: - Properties
    
    private let modelTypes: [any PersistentModel.Type] =
    [
        Trip.self,
        Location.self
    ]
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            TripListView()
        }
        .modelContainer(for: modelTypes)
    }
}
