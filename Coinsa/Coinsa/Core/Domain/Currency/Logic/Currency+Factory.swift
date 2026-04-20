//
//  Currency+Factory.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

extension Currency {
    static func from(_ code: String) -> Currency {
        Currency(rawValue: code.uppercased()) ?? .defaultValue
    }
}
