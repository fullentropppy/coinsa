//
//  Trip+Locations.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.04.2026.
//

extension Trip {
    var hasLocations: Bool {
        locations?.isEmpty == false
    }
    
    var locationsCount: Int {
        locations?.count ?? 0
    }
}
