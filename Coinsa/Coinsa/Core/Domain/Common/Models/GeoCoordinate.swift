//
//  GeoCoordinate.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.08.2026.
//

import CoreLocation
import Foundation

/// Географические координаты с опциональной точностью определения.
struct GeoCoordinate: Equatable {
    // MARK: - Свойства

    let latitude: Double
    let longitude: Double
    let horizontalAccuracy: Double?

    var locationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var formattedDescription: String {
        let coordinateText = String(
            format: "%.5f, %.5f",
            latitude,
            longitude
        )

        guard let horizontalAccuracy else {
            return coordinateText
        }

        return coordinateText + String(format: " ± %.0f m", horizontalAccuracy)
    }

    // MARK: - Инициализация

    init(latitude: Double, longitude: Double, horizontalAccuracy: Double?) {
        self.latitude = latitude
        self.longitude = longitude
        self.horizontalAccuracy = horizontalAccuracy
    }

    init(_ locationCoordinate: CLLocationCoordinate2D, horizontalAccuracy: Double?) {
        self.init(
            latitude: locationCoordinate.latitude,
            longitude: locationCoordinate.longitude,
            horizontalAccuracy: horizontalAccuracy
        )
    }

    init(_ location: CLLocation) {
        let horizontalAccuracy = location.horizontalAccuracy >= 0 ? location.horizontalAccuracy : nil

        self.init(
            location.coordinate,
            horizontalAccuracy: horizontalAccuracy
        )
    }
}
