//
//  LocationStore.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.03.2026.
//

import Foundation
import SwiftData

@MainActor
struct LocationStore {
    // MARK: - Stored Properties

    let context: ModelContext

    // MARK: - Public Methods
    
    func delete(_ location: Location) {
        context.delete(location)
    }
}
