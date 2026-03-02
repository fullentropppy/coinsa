//
//  TripDeletionHandler.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.03.2026.
//

import SwiftUI

struct TripDeletionHandler {
    var isShowingDeleteConfirmation = false
    var tripsPendingDeletion: [Trip] = []

    var confirmationMessage: LocalizedStringKey {
        tripsPendingDeletion.count == 1
        ? "trip.deletionConfirmation.message.single"
        : "trip.deletionConfirmation.message.multiple"
    }

    mutating func requestDelete(trips: [Trip]) {
        tripsPendingDeletion = trips
        isShowingDeleteConfirmation = true
    }

    mutating func confirmDelete(using store: TripStore) {
        tripsPendingDeletion.forEach { store.delete($0) }
        tripsPendingDeletion.removeAll()
    }

    mutating func cancelDelete() {
        tripsPendingDeletion.removeAll()
    }
}
