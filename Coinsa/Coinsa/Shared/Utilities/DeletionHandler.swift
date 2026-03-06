//
//  DeletionHandler.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 05.03.2026.
//

import SwiftUI

struct DeletionHandler<Item> {
    // MARK: - Stored Properties

    private let singleMessageKey: LocalizedStringKey
    private let multipleMessageKey: LocalizedStringKey
    
    var isShowingDeleteConfirmation = false
    var itemsPendingDeletion: [Item] = []

    // MARK: - Initialization

    init(singleMessageKey: LocalizedStringKey, multipleMessageKey: LocalizedStringKey) {
        self.singleMessageKey = singleMessageKey
        self.multipleMessageKey = multipleMessageKey
    }

    // MARK: - Computed Properties

    var confirmationMessage: LocalizedStringKey {
        itemsPendingDeletion.count == 1 ? singleMessageKey : multipleMessageKey
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
