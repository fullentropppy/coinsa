//
//  HexarateService.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 07.04.2026.
//

import Foundation

/// Реализация сервиса курсов валют через API Hexarate.
final class HexarateService: ExchangeRateService {
    // MARK: - Публичные методы
    
    /// Получает курс обмена через Hexarate API.
    /// - Parameters:
    ///   - from: Исходная валюта.
    ///   - to: Целевая валюта.
    /// - Returns: Курс обмена (сколько единиц `to` за 1 единицу `from`).
    /// - Throws: Ошибки сети, декодирования или невалидного URL.
    func fetchRate(from: Currency, to: Currency) async throws -> Double {
        let url = URL(string: "https://hexarate.paikama.co/api/rates/\(from.code)/\(to.code)/latest")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(Response.self, from: data)
        return response.data.mid
    }
}

// MARK: - Внутренние типы составляющие ответ Hexarate

/// Корневой ответ API Hexarate.
private struct Response: Decodable {
    let data: RateData
}

/// Данные о курсе в ответе API.
private struct RateData: Decodable {
    let mid: Double
}
