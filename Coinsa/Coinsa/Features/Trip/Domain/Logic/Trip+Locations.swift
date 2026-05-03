//
//  Trip+Locations.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.04.2026.
//

extension Trip {
    /// Признак наличия локаций в поездке.
    var hasLocations: Bool {
        locations?.isEmpty == false
    }
    
    /// Количество локаций в поездке.
    var locationsCount: Int {
        locations?.count ?? 0
    }
}
