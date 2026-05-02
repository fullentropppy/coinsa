//
//  DemoDataService.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.04.2026.
//

#if DEBUG

import SwiftData

/// Сервис для управления демонстрационными данными в отладочных сборках.
@MainActor
struct DemoDataService {
    // MARK: - Свойства

    private let context: ModelContext

    // MARK: - Инициализация

    /// Создаёт сервис для работы с демо-данными.
    /// - Parameter context: Контекст модели SwiftData.
    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Публичные методы

    /// Проверяет, есть ли в базе данных какие-либо поездки.
    /// - Returns: `true`, если в базе уже есть данные.
    func hasExistingData() -> Bool {
        let descriptor = FetchDescriptor<Trip>()
        let trips = try? context.fetch(descriptor)
        return trips?.isEmpty == false
    }

    /// Загружает демонстрационные данные в базу.
    /// Предварительно удаляет все существующие данные.
    /// - Throws: Ошибки при удалении существующих данных или сохранении новых.
    func loadDemoData() throws {
        try deleteAllData()
        let trips = PreviewBuilder.builder().withScenario(.all).buildData()
        trips.forEach { context.insert($0) }
        try context.save()
    }

    /// Удаляет все поездки из базы данных.
    /// - Throws: Ошибки при получении данных или сохранении изменений.
    func deleteAllData() throws {
        let descriptor = FetchDescriptor<Trip>()
        let trips = try context.fetch(descriptor)
        
        for trip in trips {
            context.delete(trip)
        }
        
        try context.save()
    }
}

#endif
