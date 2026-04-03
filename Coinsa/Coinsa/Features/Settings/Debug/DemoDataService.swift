//
//  DemoDataService.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.04.2026.
//

#if DEBUG

import SwiftData

@MainActor
struct DemoDataService {
    // MARK: - Stored Properties

    private let context: ModelContext

    // MARK: - Initialization

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Public Methods

    func hasExistingData() -> Bool {
        let descriptor = FetchDescriptor<Trip>()
        let trips = try? context.fetch(descriptor)
        return trips?.isEmpty == false
    }

    func loadDemoData() throws {
        try deleteAllData()
        let trips = PreviewBuilder.builder().withScenario(.all).buildData()
        trips.forEach { context.insert($0) }
        try context.save()
    }

    func deleteAllData() throws {
        try context.delete(model: Trip.self)
        try context.save()
    }
}

#endif
