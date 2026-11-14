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
    private var continuations: [UUID: CheckedContinuation<CLLocation, Error>] = [:]

    // MARK: - Инициализация

    /// Создает провайдер геопозиции с точностью до сотни метров и настраивает делегат.
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 50
    }

    // MARK: - Операции

    func requestCurrentLocation() async throws -> CLLocation {
        let requestID = UUID()

        return try await withTaskCancellationHandler {
            try Task.checkCancellation()
            return try await withCheckedThrowingContinuation { continuation in
                guard !Task.isCancelled else {
                    continuation.resume(throwing: CancellationError())
                    return
                }

                let shouldStartRequest = continuations.isEmpty
                continuations[requestID] = continuation
                if shouldStartRequest {
                    requestAuthorizationOrLocation()
                }
            }
        } onCancel: {
            Task { @MainActor in
                self.continuations.removeValue(forKey: requestID)?.resume(throwing: CancellationError())
            }
        }
    }

    private func requestAuthorizationOrLocation() {
        if continuations.isEmpty {
            return
        }
        
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
        let pending = continuations.values
        continuations.removeAll()
        for continuation in pending {
            continuation.resume(returning: location)
        }
    }

    private func resume(throwing error: Error) {
        let pending = continuations.values
        continuations.removeAll()
        for continuation in pending {
            continuation.resume(throwing: error)
        }
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
        if let location = locations.last {
            Task { @MainActor in
                resume(returning: location)
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            resume(throwing: error)
        }
    }
}
