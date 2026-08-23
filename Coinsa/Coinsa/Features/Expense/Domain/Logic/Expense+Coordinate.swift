//
//  Expense+Coordinate.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.08.2026.
//

extension Expense {
    /// Координаты места совершения траты.
    var coordinate: GeoCoordinate? {
        guard let latitude, let longitude else { return nil }

        return GeoCoordinate(
            latitude: latitude,
            longitude: longitude,
            horizontalAccuracy: horizontalAccuracy
        )
    }
}
