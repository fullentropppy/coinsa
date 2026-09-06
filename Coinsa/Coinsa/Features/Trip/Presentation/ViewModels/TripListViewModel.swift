//
//  TripListViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 11.04.2026.
//

/// ViewModel для списка поездок.
struct TripListViewModel {
    /// Группирует поездки по статусу и сортирует внутри каждой группы.
    /// - Parameter trips: Массив поездок для группировки.
    /// - Returns: Массив кортежей (статус, отсортированные поездки) в порядке: активные, предстоящие, завершенные.
    func groupedTrips(from trips: [Trip]) -> [(status: EventStatus, trips: [Trip])] {
        let grouped = Dictionary(grouping: trips) { $0.status }
        let statusOrder: [EventStatus] = [.ongoing, .upcoming, .completed]
        
        return statusOrder.compactMap { status in
            guard var tripsForStatus = grouped[status] else { return nil }
            
            switch status {
            case .ongoing:
                tripsForStatus.sort {
                    if $0.startPlainDate != $1.startPlainDate {
                        return $0.startPlainDate > $1.startPlainDate
                    }
                    if $0.totalDays != $1.totalDays {
                        return $0.totalDays < $1.totalDays
                    }
                    if $0.endPlainDate != $1.endPlainDate {
                        return $0.endPlainDate < $1.endPlainDate
                    }
                    return $0.updatedAt > $1.updatedAt
                }
                
            case .upcoming:
                tripsForStatus.sort {
                    if $0.startPlainDate != $1.startPlainDate {
                        return $0.startPlainDate < $1.startPlainDate
                    }
                    if $0.totalDays != $1.totalDays {
                        return $0.totalDays < $1.totalDays
                    }
                    if $0.endPlainDate != $1.endPlainDate {
                        return $0.endPlainDate < $1.endPlainDate
                    }
                    return $0.updatedAt > $1.updatedAt
                }
                
            case .completed:
                tripsForStatus.sort {
                    if $0.startPlainDate != $1.startPlainDate {
                        return $0.startPlainDate > $1.startPlainDate
                    }
                    if $0.totalDays != $1.totalDays {
                        return $0.totalDays < $1.totalDays
                    }
                    if $0.endPlainDate != $1.endPlainDate {
                        return $0.endPlainDate < $1.endPlainDate
                    }
                    return $0.updatedAt > $1.updatedAt
                }
            }
            
            return (status, tripsForStatus)
        }
    }
}
