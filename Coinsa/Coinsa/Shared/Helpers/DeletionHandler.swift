//
//  DeletionHandler.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 05.03.2026.
//

import SwiftUI

struct DeletionHandler<Item> {
    // MARK: - Stored Properties

    var isShowingDeleteConfirmation = false
    var itemsPendingDeletion: [Item] = []
    
    // MARK: - Public Methods

    mutating func request(for items: [Item]) {
        itemsPendingDeletion = items
        isShowingDeleteConfirmation = true
    }

    mutating func confirm(using deleteAction: (Item) -> Void) {
        itemsPendingDeletion.forEach(deleteAction)
        itemsPendingDeletion.removeAll()
    }

    mutating func cancel() {
        itemsPendingDeletion.removeAll()
    }
}
