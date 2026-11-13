//
//  ExpenseMapViewport.swift
//  Coinsa
//

import MapKit

/// Область карты с кратчайшим охватом долгот, включая переход через 180-й меридиан.
enum ExpenseMapViewport {
    static func boundingRect(for coordinates: [CLLocationCoordinate2D]) -> MKMapRect? {
        let points = coordinates
            .filter { $0.latitude.isFinite && $0.longitude.isFinite && CLLocationCoordinate2DIsValid($0) }
            .map { MKMapPoint($0) }
            .filter { $0.x.isFinite && $0.y.isFinite }
            .sorted { $0.x < $1.x }

        guard let first = points.first, let last = points.last else { return nil }

        let worldWidth = MKMapRect.world.size.width
        var largestGap = first.x + worldWidth - last.x
        var startX = first.x

        for index in points.indices.dropFirst() {
            let gap = points[index].x - points[index - 1].x
            if gap > largestGap {
                largestGap = gap
                startX = points[index].x
            }
        }

        let minY = points.map(\.y).min() ?? first.y
        let maxY = points.map(\.y).max() ?? first.y

        return MKMapRect(
            x: startX,
            y: minY,
            width: max(0, worldWidth - largestGap),
            height: maxY - minY
        )
    }

    static func visibleRect(for coordinates: [CLLocationCoordinate2D]) -> MKMapRect? {
        guard let bounds = boundingRect(for: coordinates) else { return nil }

        let center = MKMapPoint(x: bounds.midX, y: bounds.midY)
        let minimumSize = 400 * MKMapPointsPerMeterAtLatitude(center.coordinate.latitude)
        let width = max(bounds.width, minimumSize)
        let height = max(bounds.height, minimumSize)

        return MKMapRect(
            x: center.x - width / 2,
            y: center.y - height / 2,
            width: width,
            height: height
        )
    }
}
