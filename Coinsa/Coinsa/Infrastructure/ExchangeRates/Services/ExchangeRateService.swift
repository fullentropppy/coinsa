//
//  ExchangeRateService.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 07.04.2026.
//

/// Протокол сервиса для получения курсов обмена валют.
protocol ExchangeRateService {
    /// Получает текущий курс обмена между двумя валютами.
    /// - Parameters:
    ///   - from: Исходная валюта.
    ///   - to: Целевая валюта.
    /// - Returns: Курс обмена (сколько единиц `to` за 1 единицу `from`).
    /// - Throws: Ошибки сети, декодирования или специфичную для сервиса.
    func fetchRate(from: Currency, to: Currency) async throws -> Double
}
