//
//  LocationGrouping.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.11.2026.
//

/// Общая группировка и сортировка локаций поездки.
enum LocationGrouping {
    static func grouped(_ locations: [Location]) -> [(status: EventStatus, locations: [Location])] {
        let grouped = Dictionary(grouping: locations) { $0.status }
        let statusOrder: [EventStatus] = [.ongoing, .upcoming, .completed]

        return statusOrder.compactMap { status in
            guard let locationsForStatus = grouped[status] else { return nil }

            let sortedLocations = locationsForStatus.sorted {
                if $0.startPlainDate != $1.startPlainDate {
                    return status == .ongoing
                        ? $0.startPlainDate > $1.startPlainDate
                        : $0.startPlainDate < $1.startPlainDate
                }
                if $0.totalDays != $1.totalDays {
                    return $0.totalDays < $1.totalDays
                }
                if $0.endPlainDate != $1.endPlainDate {
                    return $0.endPlainDate < $1.endPlainDate
                }
                return $0.updatedAt > $1.updatedAt
            }

            return (status, sortedLocations)
        }
    }
}
