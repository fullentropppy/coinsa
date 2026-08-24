//
//  CurrentLocationProvider.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.08.2026.
//

import CoreLocation
import Foundation

/// Запрашивает текущую геопозицию пользователя один раз.
@MainActor
final class CurrentLocationProvider: NSObject {
    // MARK: - Состояние

    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?

    // MARK: - Инициализация

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 50
    }

    // MARK: - Операции

    func requestCurrentLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            requestAuthorizationOrLocation()
        }
    }

    private func requestAuthorizationOrLocation() {
        guard continuation != nil else { return }

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case .denied, .restricted:
            resume(throwing: CLError(.denied))
        @unknown default:
            resume(throwing: CLError(.locationUnknown))
        }
    }

    private func resume(returning location: CLLocation) {
        continuation?.resume(returning: location)
        continuation = nil
    }

    private func resume(throwing error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

// MARK: - CLLocationManagerDelegate

extension CurrentLocationProvider: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            requestAuthorizationOrLocation()
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }

        Task { @MainActor in
            resume(returning: location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            resume(throwing: error)
        }
    }
}
