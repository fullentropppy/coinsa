//
//  CoinsaApp.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 26.02.2026.
//

import SwiftUI
import SwiftData

/// Главная точка входа в приложение.
@main
struct CoinsaApp: App {
    // MARK: - Свойства
    
    /// Контейнер модели SwiftData с поддержкой CloudKit.
    private let container: ModelContainer = {
        let schema = Schema([
            Trip.self,
            Location.self,
            Budget.self,
            Expense.self
        ])

        let config = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .private(AppInfo.iCloudContainerIdentifier)
        )

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create container: \(error)")
        }
    }()
    
    // MARK: - Тело View
    
    var body: some Scene {
        WindowGroup {
            RootContainerView()
        }
        .modelContainer(container)
    }
}
