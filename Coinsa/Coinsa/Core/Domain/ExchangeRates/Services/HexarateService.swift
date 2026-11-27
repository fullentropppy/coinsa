//
//  HexarateService.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 07.04.2026.
//

import Foundation

/// Реализация сервиса курсов валют через API Hexarate.
final class HexarateService: ExchangeRateService {
    // MARK: - Свойства

    private let session: URLSession
    private let settingsManager: UserDefaultsSettingsManager

    // MARK: - Инициализация

    /// Создает сервис с возможностью изолированно проверить загрузку и ошибки сети.
    /// - Parameters:
    ///   - session: Сессия для запросов курсов; по умолчанию общая сессия приложения.
    ///   - defaults: Хранилище настройки кэширования, читаемой перед каждым запросом.
    init(session: URLSession = .shared, defaults: UserDefaults = .standard) {
        self.session = session
        settingsManager = UserDefaultsSettingsManager(defaults: defaults)
    }

    // MARK: - Публичные методы
    
    /// Получает курс обмена через Hexarate API.
    /// - Parameters:
    ///   - from: Исходная валюта.
    ///   - to: Целевая валюта.
    /// - Returns: Курс обмена (сколько единиц `to` за 1 единицу `from`).
    /// - Throws: Ошибки сети, HTTP-ответа, декодирования или некорректного курса.
    func fetchRate(from: Currency, to: Currency) async throws -> Double {
        let url = URL(string: "https://hexarate.paikama.co/api/rates/\(from.code)/\(to.code)/latest")!
        let cachePolicy: URLRequest.CachePolicy = settingsManager.cacheExchangeRates
            ? .useProtocolCachePolicy
            : .reloadIgnoringLocalCacheData
        let request = URLRequest(url: url, cachePolicy: cachePolicy)
        let (data, urlResponse) = try await session.data(for: request)
        try Task.checkCancellation()
        guard let httpResponse = urlResponse as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw ExchangeRateLoadingError()
        }

        let response = try JSONDecoder().decode(Response.self, from: data)
        guard response.data.mid.isFinite, response.data.mid > 0 else {
            throw ExchangeRateLoadingError()
        }
        return response.data.mid
    }
}

// MARK: - Внутренние типы, составляющие ответ Hexarate

/// Корневой ответ API Hexarate.
private struct Response: Decodable {
    let data: RateData
}

/// Данные о курсе в ответе API.
private struct RateData: Decodable {
    let mid: Double
}
