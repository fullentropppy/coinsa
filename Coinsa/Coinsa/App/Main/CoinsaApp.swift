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
    
    private let container: ModelContainer = {
        let schema = Schema([
            Trip.self,
            Location.self,
            Budget.self,
            Expense.self
        ])
        
#if DEBUG
        let privateDBName = "iCloud.ru.dgritsenko.Coinsa.debug"
#else
        let privateDBName = "iCloud.ru.dgritsenko.Coinsa"
#endif

        let config = ModelConfiguration(schema: schema, cloudKitDatabase: .private(privateDBName))

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
