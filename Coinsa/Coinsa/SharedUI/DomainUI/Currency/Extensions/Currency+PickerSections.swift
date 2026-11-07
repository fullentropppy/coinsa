//
//  Currency+PickerSections.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.11.2026.
//

import Foundation

extension Currency {
    /// Формирует секции для пикера: приоритетные сверху, остальные - ниже.
    /// - Parameters:
    ///   - homeCurrency: Домашняя валюта.
    ///   - locationCurrency: Валюта локации (опционально).
    static func pickerSections(
        homeCurrency: Currency,
        locationCurrency: Currency? = nil
    ) -> [PickerSection<Currency>] {
        var sections: [PickerSection<Currency>] = []
        var prioritized: [Currency] = []
        
        if let locationCurrency {
            prioritized.append(locationCurrency)
        }
        
        if !prioritized.contains(homeCurrency) {
            prioritized.append(homeCurrency)
        }
        
        if !prioritized.contains(.usd) {
            prioritized.append(.usd)
        }
        
        if !prioritized.contains(.eur) {
            prioritized.append(.eur)
        }
        
        let rest = allCasesSortedByName.filter { !prioritized.contains($0) }
        
        if !prioritized.isEmpty {
            sections.append(PickerSection(options: prioritized))
        }
        
        if !rest.isEmpty {
            sections.append(PickerSection(options: rest))
        }
        
        return sections
    }
}
