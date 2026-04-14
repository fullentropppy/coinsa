//
//  DeletionHandler.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 05.03.2026.
//

import SwiftUI

struct DeletionHandler<Item> {
    // MARK: - Свойства

    var isShowingDeleteConfirmation = false
    var itemsPendingDeletion: [Item] = []
    
    // MARK: - Публичные методы

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
