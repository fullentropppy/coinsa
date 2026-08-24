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

    var coreLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // MARK: - Инициализация

    /// Создает географические координаты.
    /// - Parameters:
    ///   - latitude: Широта в градусах.
    ///   - longitude: Долгота в градусах.
    ///   - horizontalAccuracy: Горизонтальная точность в метрах. `nil` если неизвестна.
    init(latitude: Double, longitude: Double, horizontalAccuracy: Double?) {
        self.latitude = latitude
        self.longitude = longitude
        self.horizontalAccuracy = horizontalAccuracy
    }

    /// Создает географические координаты из координат Core Location.
    /// - Parameters:
    ///   - coreLocationCoordinate: Координата в формате Core Location.
    ///   - horizontalAccuracy: Горизонтальная точность в метрах. `nil` если неизвестна.
    init(_ coreLocationCoordinate: CLLocationCoordinate2D, horizontalAccuracy: Double?) {
        self.init(
            latitude: coreLocationCoordinate.latitude,
            longitude: coreLocationCoordinate.longitude,
            horizontalAccuracy: horizontalAccuracy
        )
    }

    /// Создает географические координаты из объекта Core Location.
    /// - Parameter coreLocation: Объект местоположения Core Location.
    ///                         Отрицательные значения `horizontalAccuracy` интерпретируются как `nil`.
    init(_ coreLocation: CLLocation) {
        let horizontalAccuracy = coreLocation.horizontalAccuracy >= 0 ? coreLocation.horizontalAccuracy : nil
        self.init(coreLocation.coordinate, horizontalAccuracy: horizontalAccuracy)
    }
}
