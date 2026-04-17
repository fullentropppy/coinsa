//
//  TripListViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 11.04.2026.
//

struct TripListViewModel {
    func groupedTrips(from trips: [Trip]) -> [(status: EventStatus, trips: [Trip])] {
        let grouped = Dictionary(grouping: trips) { $0.status }
        let statusOrder: [EventStatus] = [.ongoing, .upcoming, .completed]
        
        return statusOrder.compactMap { status in
            guard var tripsForStatus = grouped[status] else { return nil }
            
            switch status {
            case .ongoing: tripsForStatus.sort { $0.startDate > $1.startDate }
            case .upcoming: tripsForStatus.sort { $0.startDate < $1.startDate }
            case .completed: tripsForStatus.sort { $0.endDate > $1.endDate }
            }
            
            return (status, tripsForStatus)
        }
    }
}
