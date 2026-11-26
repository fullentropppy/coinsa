//
//  DataTransferArchive.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.11.2026.
//

import Foundation

/// Версионируемый снимок данных со связями по UUID без служебных идентификаторов SwiftData и CloudKit.
/// Календарные компоненты записываются строками, а метаданные Date — без потери точности,
/// числом секунд относительно 01.01.2001 UTC через стандартное кодирование Foundation.
nonisolated struct DataTransferArchive: Codable, Equatable, Sendable {
    // MARK: - Свойства

    var format = "ru.dgritsenko.coinsa.archive"
    var schemaVersion = 3
    var exportedAt: Date
    var appVersion: String
    var appBuild: String
    var trips: [TripRecord]
    var locations: [LocationRecord]
    var expenses: [ExpenseRecord]

    // MARK: - Записи снимка

    /// Сохраненные поля поездки без обратного списка дочерних локаций.
    struct TripRecord: Codable, Equatable, Identifiable, Sendable {
        var id: UUID
        var name: String
        var startDate: String
        var endDate: String
        var homeCurrencyCode: String
        var generalExpensesBudget: Double = 0
        var createdAt: Date
        var updatedAt: Date
    }

    /// Сохраненные поля локации со ссылкой на родительскую поездку по UUID.
    struct LocationRecord: Codable, Equatable, Identifiable, Sendable {
        var id: UUID
        var tripID: UUID
        var name: String
        var startDate: String
        var endDate: String
        var locationCurrencyCode: String
        var rateLocationToHome: Double
        var exchangeAdjustment: Double
        var budget: Double
        var createdAt: Date
        var updatedAt: Date
    }

    /// Полный снимок траты с независимыми гражданскими компонентами и метаданными момента.
    struct ExpenseRecord: Codable, Equatable, Identifiable, Sendable {
        var id: UUID
        @RequiredNullable var locationID: UUID?
        @RequiredNullable var tripID: UUID? = nil
        var civilDateTime: String
        @RequiredNullable var actualDate: Date?
        @RequiredNullable var timeZoneID: String?
        var homeAmount: Double
        var expenseCurrencyCode: String
        var rateExpenseToHome: Double
        var rateExpenseToLocation: Double
        var paymentMethodRaw: String
        var exchangeAdjustment: Double
        var categoryRaw: String
        var subcategoryRaw: String
        @RequiredNullable var latitude: Double?
        @RequiredNullable var longitude: Double?
        @RequiredNullable var horizontalAccuracy: Double?
        @RequiredNullable var comment: String?
        var isExcludedFromDailySpending = false
        var createdAt: Date
        var updatedAt: Date
    }
}

extension DataTransferArchive.TripRecord {
    /// Читает поездку; в файлах до версии 3 бюджет общих трат отсутствует.
    /// - Parameter decoder: Декодер записи поддерживаемой версии файла.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        startDate = try container.decode(String.self, forKey: .startDate)
        endDate = try container.decode(String.self, forKey: .endDate)
        homeCurrencyCode = try container.decode(String.self, forKey: .homeCurrencyCode)
        generalExpensesBudget = container.contains(.generalExpensesBudget)
            ? try container.decode(Double.self, forKey: .generalExpensesBudget) : 0
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}

extension DataTransferArchive.ExpenseRecord {
    /// Читает снимок траты, сохраняя прежний дневной учет для файлов без нового признака.
    /// - Parameter decoder: Декодер записи из поддерживаемой версии файла.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        _locationID = try container.decode(RequiredNullable<UUID>.self, forKey: .locationID)
        _tripID = container.contains(.tripID)
            ? try container.decode(RequiredNullable<UUID>.self, forKey: .tripID) : RequiredNullable(wrappedValue: nil)
        civilDateTime = try container.decode(String.self, forKey: .civilDateTime)
        _actualDate = try container.decode(RequiredNullable<Date>.self, forKey: .actualDate)
        _timeZoneID = try container.decode(RequiredNullable<String>.self, forKey: .timeZoneID)
        homeAmount = try container.decode(Double.self, forKey: .homeAmount)
        expenseCurrencyCode = try container.decode(String.self, forKey: .expenseCurrencyCode)
        rateExpenseToHome = try container.decode(Double.self, forKey: .rateExpenseToHome)
        rateExpenseToLocation = try container.decode(Double.self, forKey: .rateExpenseToLocation)
        paymentMethodRaw = try container.decode(String.self, forKey: .paymentMethodRaw)
        exchangeAdjustment = try container.decode(Double.self, forKey: .exchangeAdjustment)
        categoryRaw = try container.decode(String.self, forKey: .categoryRaw)
        subcategoryRaw = try container.decode(String.self, forKey: .subcategoryRaw)
        _latitude = try container.decode(RequiredNullable<Double>.self, forKey: .latitude)
        _longitude = try container.decode(RequiredNullable<Double>.self, forKey: .longitude)
        _horizontalAccuracy = try container.decode(RequiredNullable<Double>.self, forKey: .horizontalAccuracy)
        _comment = try container.decode(RequiredNullable<String>.self, forKey: .comment)
        isExcludedFromDailySpending = container.contains(.isExcludedFromDailySpending)
            ? try container.decode(Bool.self, forKey: .isExcludedFromDailySpending) : false
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}

/// Отличает явное отсутствие значения от пропущенного обязательного ключа файла.
@propertyWrapper
nonisolated struct RequiredNullable<Value: Codable & Equatable & Sendable>: Codable, Equatable, Sendable {
    // MARK: - Свойства

    var wrappedValue: Value?

    // MARK: - Инициализация

    /// Сохраняет необязательное значение, ключ которого обязателен в формате файла.
    /// - Parameter wrappedValue: Значение или явное отсутствие значения.
    init(wrappedValue: Value?) {
        self.wrappedValue = wrappedValue
    }

    /// Декодирует присутствующий ключ, допускающий JSON null.
    /// - Parameter decoder: Декодер значения обязательного ключа.
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = container.decodeNil() ? nil : try container.decode(Value.self)
    }

    // MARK: - Кодирование

    /// Записывает обязательный ключ, используя явный JSON null при отсутствии значения.
    /// - Parameter encoder: Кодер значения обязательного ключа.
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let wrappedValue {
            try container.encode(wrappedValue)
        } else {
            try container.encodeNil()
        }
    }
}

/// Причины отказа до изменения постоянных данных.
nonisolated enum DataTransferError: Error, Equatable {
    // MARK: - Значения

    case invalidFile
    case unsupportedVersion
    case duplicateID
    case invalidRelationships
    case invalidValues
    case currencyConflict
    case changedSincePreview
    case localChanges
    case fileTooLarge
}

/// Кодирование снимков без округления чисел и метаданных времени.
nonisolated enum DataTransferCodec {
    // MARK: - Константы

    static let maximumFileSize = 20 * 1_024 * 1_024
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    // MARK: - Кодирование и чтение

    /// Проверяет и кодирует снимок, сохраняя исходную точность чисел и ограничение размера файла.
    /// - Parameter archive: Полный снимок связанных записей.
    /// - Returns: JSON-содержимое файла Coinsa.
    static func encode(_ archive: DataTransferArchive) throws -> Data {
        try DataTransferValidation.validate(archive)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(archive)
        guard data.count <= maximumFileSize else { throw DataTransferError.fileTooLarge }
        return data
    }

    /// Проверяет версию, обязательные поля и целостность файла до передачи данных в импорт.
    /// - Parameter data: Содержимое файла с ограниченным размером.
    /// - Returns: Декодированный снимок без исправления или нормализации его значений.
    static func decode(_ data: Data) throws -> DataTransferArchive {
        guard data.count <= maximumFileSize else { throw DataTransferError.fileTooLarge }
        let archive: DataTransferArchive
        do {
            let header = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard header?["format"] as? String == "ru.dgritsenko.coinsa.archive" else {
                throw DataTransferError.invalidFile
            }
            guard let version = header?["schemaVersion"] as? Int, (1...3).contains(version) else {
                throw DataTransferError.unsupportedVersion
            }
            if version >= 2, let expenses = header?["expenses"] as? [[String: Any]],
               expenses.contains(where: { $0["isExcludedFromDailySpending"] == nil }) {
                throw DataTransferError.invalidFile
            }
            if version == 3 {
                guard let trips = header?["trips"] as? [[String: Any]],
                      let expenses = header?["expenses"] as? [[String: Any]],
                      trips.allSatisfy({ $0["generalExpensesBudget"] != nil }),
                      expenses.allSatisfy({ $0["tripID"] != nil }) else {
                    throw DataTransferError.invalidFile
                }
            }
            archive = try JSONDecoder().decode(DataTransferArchive.self, from: data)
        } catch let error as DataTransferError {
            throw error
        } catch {
            throw DataTransferError.invalidFile
        }
        try DataTransferValidation.validate(archive)
        return archive
    }

    // MARK: - Формат хранения дат

    /// Записывает календарные компоненты в стабильном формате без зависимости от пояса устройства.
    /// - Parameters:
    ///   - date: Дата в UTC-представлении календарных компонентов.
    ///   - includesTime: Добавлять гражданское время с точностью до секунд.
    /// - Returns: День или дата и время; пустая строка для неконечного значения.
    static func dateString(_ date: Date, includesTime: Bool = false) -> String {
        guard date.timeIntervalSinceReferenceDate.isFinite else { return "" }
        let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let day = String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
        if includesTime {
            return day + String(format: "T%02d:%02d:%02d", parts.hour ?? 0, parts.minute ?? 0, parts.second ?? 0)
        }
        return day
    }

    /// Читает календарные компоненты, отклоняя несуществующие даты и отклонения от формата.
    /// - Parameters:
    ///   - string: День или гражданские дата и время из файла.
    ///   - includesTime: Ожидать время с точностью до секунд.
    /// - Returns: UTC-представление компонентов без вычисления фактического момента траты.
    static func date(_ string: String, includesTime: Bool = false) throws -> Date {
        let bytes = Array(string.utf8)
        guard bytes.count == (includesTime ? 19 : 10), bytes[4] == 45, bytes[7] == 45 else {
            throw DataTransferError.invalidValues
        }
        if includesTime {
            guard bytes[10] == 84, bytes[13] == 58, bytes[16] == 58 else { throw DataTransferError.invalidValues }
        }
        let digitPositions = includesTime ? [0..<4, 5..<7, 8..<10, 11..<13, 14..<16, 17..<19] : [0..<4, 5..<7, 8..<10]
        guard digitPositions.allSatisfy({ range in bytes[range].allSatisfy { (48...57).contains($0) } }) else {
            throw DataTransferError.invalidValues
        }
        let values = digitPositions.map { range in bytes[range].reduce(0) { $0 * 10 + Int($1 - 48) } }
        var components = DateComponents(year: values[0], month: values[1], day: values[2])
        if includesTime {
            components.hour = values[3]
            components.minute = values[4]
            components.second = values[5]
        }
        guard let date = calendar.date(from: components), dateString(date, includesTime: includesTime) == string else {
            throw DataTransferError.invalidValues
        }
        return date
    }
}
