//
//  LocationDeletionHandler.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.03.2026.
//

import SwiftUI

struct LocationDeletionHandler {
    // MARK: - Stored Properties
    
    var isShowingDeleteConfirmation = false
    var locationsPendingDeletion: [Location] = []

    // MARK: - Computed Properties
    
    var confirmationMessage: LocalizedStringKey {
        locationsPendingDeletion.count == 1
        ? "location.deletionConfirmation.message.single"
        : "location.deletionConfirmation.message.multiple"
    }

    // MARK: - Public Methods
    
    mutating func requestDelete(locations: [Location]) {
        locationsPendingDeletion = locations
        isShowingDeleteConfirmation = true
    }

    mutating func confirmDelete(using store: LocationStore) {
        locationsPendingDeletion.forEach { store.delete($0) }
        locationsPendingDeletion.removeAll()
    }

    mutating func cancelDelete() {
        locationsPendingDeletion.removeAll()
    }
}
