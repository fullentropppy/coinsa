//
//  HexarateService.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 07.04.2026.
//

import Foundation

final class HexarateService: ExchangeRateService {
    // MARK: - Публичные методы
    
    func fetchRate(from: Currency, to: Currency) async throws -> Double {
        let url = URL(string: "https://hexarate.paikama.co/api/rates/\(from.code)/\(to.code)/latest")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(Response.self, from: data)
        return response.data.mid
    }
}

// MARK: - Внутренние типы составляющие ответ Hexarate

private struct Response: Decodable {
    let data: RateData
}

private struct RateData: Decodable {
    let mid: Double
}
