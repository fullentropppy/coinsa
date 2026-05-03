//
//  DeletionHandler.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 05.03.2026.
//

/// Утилита для управления удалением элементов с подтверждением.
struct DeletionHandler<Item> {
    // MARK: - Свойства

    var isShowingDeleteConfirmation = false
    var itemsPendingDeletion: [Item] = []
    
    // MARK: - Публичные методы

    /// Запрашивает подтверждение на удаление переданных элементов.
    /// - Parameter items: Элементы, которые планируется удалить.
    mutating func request(for items: [Item]) {
        itemsPendingDeletion = items
        isShowingDeleteConfirmation = true
    }

    /// Подтверждает удаление и выполняет действие для каждого элемента.
    /// - Parameter deleteAction: Замыкание, удаляющее один элемент.
    mutating func confirm(using deleteAction: (Item) -> Void) {
        itemsPendingDeletion.forEach(deleteAction)
        itemsPendingDeletion.removeAll()
    }

    /// Отменяет удаление, очищая список ожидающих элементов.
    mutating func cancel() {
        itemsPendingDeletion.removeAll()
    }
}
