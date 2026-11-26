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
    var schemaVersion = 1
    var exportedAt: Date
    var appVersion: String
    var appBuild: String
    var trips: [TripRecord]
    var locations: [LocationRecord]
    var expenses: [ExpenseRecord]
    var hasExportedAt = true

    private enum CodingKeys: String, CodingKey {
        case format, schemaVersion, exportedAt, appVersion, appBuild, trips, locations, expenses
    }

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
        var hasUpdatedAt = true

        private enum CodingKeys: String, CodingKey {
            case id, name, startDate, endDate, homeCurrencyCode, generalExpensesBudget, createdAt, updatedAt
        }
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
        var hasUpdatedAt = true

        private enum CodingKeys: String, CodingKey {
            case id, tripID, name, startDate, endDate, locationCurrencyCode
            case rateLocationToHome, exchangeAdjustment, budget, createdAt, updatedAt
        }
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
        var hasUpdatedAt = true
        var hasActualDate = true
        var hasTimeZoneID = true

        private enum CodingKeys: String, CodingKey {
            case id, locationID, tripID, civilDateTime, actualDate, timeZoneID, homeAmount, expenseCurrencyCode
            case rateExpenseToHome, rateExpenseToLocation, paymentMethodRaw, exchangeAdjustment
            case categoryRaw, subcategoryRaw, latitude, longitude, horizontalAccuracy, comment
            case isExcludedFromDailySpending, createdAt, updatedAt
        }
    }
}

extension DataTransferArchive {
    /// Читает единый формат, дополняя отсутствующие служебные поля и пустые списки.
    /// - Parameter decoder: Декодер файла; одна опорная дата используется для всех новых метаданных.
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        format = try container.decode(String.self, forKey: .format)
        schemaVersion = try container.decode(Int.self, forKey: .schemaVersion)
        let exportedAt = try container.decodeIfPresent(Date.self, forKey: .exportedAt)
        self.exportedAt = exportedAt ?? decoder.dataTransferImportDate
        hasExportedAt = exportedAt != nil
        appVersion = try container.decodeIfPresent(String.self, forKey: .appVersion) ?? ""
        appBuild = try container.decodeIfPresent(String.self, forKey: .appBuild) ?? ""
        guard container.contains(.trips) || container.contains(.locations) || container.contains(.expenses) else {
            throw DataTransferError.invalidFile
        }
        trips = try container.decodeIfPresent([TripRecord].self, forKey: .trips) ?? []
        locations = try container.decodeIfPresent([LocationRecord].self, forKey: .locations) ?? []
        expenses = try container.decodeIfPresent([ExpenseRecord].self, forKey: .expenses) ?? []
    }
}

extension DataTransferArchive.TripRecord {
    /// Читает поездку, назначая отсутствующие UUID и служебные даты до предварительного просмотра.
    /// - Parameter decoder: Декодер записи единственного поддерживаемого формата.
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        startDate = try container.decode(String.self, forKey: .startDate)
        endDate = try container.decode(String.self, forKey: .endDate)
        homeCurrencyCode = try container.decode(String.self, forKey: .homeCurrencyCode)
        generalExpensesBudget = try container.decodeIfPresent(Double.self, forKey: .generalExpensesBudget) ?? 0
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? decoder.dataTransferImportDate
        let updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        self.updatedAt = updatedAt ?? decoder.dataTransferImportDate
        hasUpdatedAt = updatedAt != nil
    }
}

extension DataTransferArchive.LocationRecord {
    /// Читает локацию с обязательным UUID поездки и необязательными служебными метаданными.
    /// - Parameter decoder: Декодер записи; поездка может находиться в файле или локальной базе.
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        tripID = try container.decode(UUID.self, forKey: .tripID)
        name = try container.decode(String.self, forKey: .name)
        startDate = try container.decode(String.self, forKey: .startDate)
        endDate = try container.decode(String.self, forKey: .endDate)
        locationCurrencyCode = try container.decode(String.self, forKey: .locationCurrencyCode)
        rateLocationToHome = try container.decode(Double.self, forKey: .rateLocationToHome)
        exchangeAdjustment = try container.decodeIfPresent(Double.self, forKey: .exchangeAdjustment) ?? 0
        budget = try container.decodeIfPresent(Double.self, forKey: .budget) ?? 0
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? decoder.dataTransferImportDate
        let updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        self.updatedAt = updatedAt ?? decoder.dataTransferImportDate
        hasUpdatedAt = updatedAt != nil
    }
}

extension DataTransferArchive.ExpenseRecord {
    /// Читает трату с обязательным единственным владельцем, не выдумывая фактический момент и пояс.
    /// - Parameter decoder: Декодер записи; пропущенные необязательные поля равнозначны отсутствующим данным.
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        let locationID = try container.decodeIfPresent(UUID.self, forKey: .locationID)
        let tripID = try container.decodeIfPresent(UUID.self, forKey: .tripID)
        _locationID = RequiredNullable(wrappedValue: locationID)
        _tripID = RequiredNullable(wrappedValue: tripID)
        guard (locationID != nil) != (tripID != nil) else { throw DataTransferError.invalidRelationships }
        civilDateTime = try container.decode(String.self, forKey: .civilDateTime)
        _actualDate = RequiredNullable(wrappedValue: try container.decodeIfPresent(Date.self, forKey: .actualDate))
        _timeZoneID = RequiredNullable(wrappedValue: try container.decodeIfPresent(String.self, forKey: .timeZoneID))
        hasActualDate = container.contains(.actualDate)
        hasTimeZoneID = container.contains(.timeZoneID)
        homeAmount = try container.decode(Double.self, forKey: .homeAmount)
        expenseCurrencyCode = try container.decode(String.self, forKey: .expenseCurrencyCode)
        rateExpenseToHome = try container.decode(Double.self, forKey: .rateExpenseToHome)
        if let rate = try container.decodeIfPresent(Double.self, forKey: .rateExpenseToLocation) {
            rateExpenseToLocation = rate
        } else if tripID != nil {
            rateExpenseToLocation = rateExpenseToHome
        } else {
            throw DataTransferError.invalidValues
        }
        paymentMethodRaw = try container.decode(String.self, forKey: .paymentMethodRaw)
        exchangeAdjustment = try container.decodeIfPresent(Double.self, forKey: .exchangeAdjustment) ?? 0
        categoryRaw = try container.decode(String.self, forKey: .categoryRaw)
        subcategoryRaw = try container.decode(String.self, forKey: .subcategoryRaw)
        _latitude = RequiredNullable(wrappedValue: try container.decodeIfPresent(Double.self, forKey: .latitude))
        _longitude = RequiredNullable(wrappedValue: try container.decodeIfPresent(Double.self, forKey: .longitude))
        _horizontalAccuracy = RequiredNullable(wrappedValue: try container.decodeIfPresent(Double.self, forKey: .horizontalAccuracy))
        _comment = RequiredNullable(wrappedValue: try container.decodeIfPresent(String.self, forKey: .comment))
        isExcludedFromDailySpending = try container.decodeIfPresent(Bool.self, forKey: .isExcludedFromDailySpending) ?? false
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? decoder.dataTransferImportDate
        let updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        self.updatedAt = updatedAt ?? decoder.dataTransferImportDate
        hasUpdatedAt = updatedAt != nil
    }
}

private extension CodingUserInfoKey {
    nonisolated static let dataTransferImportDate = CodingUserInfoKey(rawValue: "dataTransferImportDate")!
}

private extension Decoder {
    nonisolated var dataTransferImportDate: Date {
        userInfo[.dataTransferImportDate] as? Date ?? Date()
    }
}

/// Сохраняет явный JSON null для необязательных полей полного экспорта.
@propertyWrapper
nonisolated struct RequiredNullable<Value: Codable & Equatable & Sendable>: Codable, Equatable, Sendable {
    // MARK: - Свойства

    var wrappedValue: Value?

    // MARK: - Инициализация

    /// Сохраняет необязательное значение, ключ которого всегда записывается при полном экспорте.
    /// - Parameter wrappedValue: Значение или явное отсутствие значения.
    init(wrappedValue: Value?) {
        self.wrappedValue = wrappedValue
    }

    /// Декодирует присутствующий ключ, допускающий JSON null.
    /// - Parameter decoder: Декодер значения обязательного ключа.
    nonisolated init(from decoder: Decoder) throws {
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

    /// Читает версию и обязательные поля; целостность связей проверяется с локальными родителями в плане импорта.
    /// - Parameter data: Содержимое файла с ограниченным размером.
    /// - Returns: Записи с назначенными UUID и метаданными; суммы и гражданские даты не пересчитываются.
    static func decode(_ data: Data) throws -> DataTransferArchive {
        guard data.count <= maximumFileSize else { throw DataTransferError.fileTooLarge }
        let archive: DataTransferArchive
        do {
            let header = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard header?["format"] as? String == "ru.dgritsenko.coinsa.archive" else {
                throw DataTransferError.invalidFile
            }
            guard header?["schemaVersion"] as? Int == 1 else {
                throw DataTransferError.unsupportedVersion
            }
            let decoder = JSONDecoder()
            decoder.userInfo[.dataTransferImportDate] = Date()
            archive = try decoder.decode(DataTransferArchive.self, from: data)
        } catch let error as DataTransferError {
            throw error
        } catch {
            throw DataTransferError.invalidFile
        }
        return archive
    }

    // MARK: - Формат хранения дат

    /// Записывает календарные компоненты в стабильном формате без зависимости от пояса устройства.
    /// - Parameters:
    ///   - date: Дата в UTC-представлении календарных компонентов.
    ///   - includesTime: Добавлять гражданское время с точностью до секунд.
    /// - Returns: День или дата и время; пустая строка для значений вне диапазона годов 0001–9999.
    static func dateString(_ date: Date, includesTime: Bool = false) -> String {
        let seconds = date.timeIntervalSinceReferenceDate
        guard seconds.isFinite, (-63_113_904_000..<252_423_993_600).contains(seconds) else { return "" }
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
