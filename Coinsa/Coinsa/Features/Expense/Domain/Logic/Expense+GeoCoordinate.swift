//
//  Expense+Coordinate.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.08.2026.
//

extension Expense {
    /// Географические координаты места совершения траты.
    var coordinate: Coordinate? {
        guard let latitude, let longitude else { return nil }

        return Coordinate(
            latitude: latitude,
            longitude: longitude,
            horizontalAccuracy: horizontalAccuracy
        )
    }
}
