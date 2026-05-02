//
//  Currency+Factory.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

extension Currency {
    /// Создаёт валюту по коду.
    /// - Parameter code: Трёхбуквенный код валюты ISO 4217.
    /// - Returns: Валюта или значение по умолчанию, если код не распознан.
    static func from(_ code: String) -> Currency {
        Currency(rawValue: code.uppercased()) ?? .defaultValue
    }
}
