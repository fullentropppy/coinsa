//
//  DeletionHandler.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 05.03.2026.
//

import SwiftUI

struct DeletionHandler<Item> {
    // MARK: - Stored Properties

    private let messageKey: LocalizedStringKey
    
    var isShowingDeleteConfirmation = false
    var itemsPendingDeletion: [Item] = []

    // MARK: - Computed Properties

    var confirmationMessage: LocalizedStringKey {
        messageKey
    }

    // MARK: - Initialization

    init(messageKey: LocalizedStringKey) {
        self.messageKey = messageKey
    }
    
    // MARK: - Public Methods

    mutating func requestDelete(items: [Item]) {
        itemsPendingDeletion = items
        isShowingDeleteConfirmation = true
    }

    mutating func confirmDelete(_ deleteAction: (Item) -> Void) {
        itemsPendingDeletion.forEach(deleteAction)
        itemsPendingDeletion.removeAll()
    }

    mutating func cancelDelete() {
        itemsPendingDeletion.removeAll()
    }
}
