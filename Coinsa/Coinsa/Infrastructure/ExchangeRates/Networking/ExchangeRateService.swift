//
//  ExchangeRateService.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 07.04.2026.
//

import Foundation

protocol ExchangeRateService {
    func fetchRate(from: Currency, to: Currency) async throws -> Double
}
