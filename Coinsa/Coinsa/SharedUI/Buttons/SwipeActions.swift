//
//  SwipeActions.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 10.04.2026.
//

import SwiftUI

/// Набор кнопок для свайп-действий в списках.
struct SwipeActions: View {
    // MARK: - Окружение
    
    @Environment(\.haptics) private var haptics
    
    // MARK: - Свойства
    
    private let onDelete: (() -> Void)?
    private let onEdit: (() -> Void)?
    private let onCopy: (() -> Void)?
    
    // MARK: - Инициализация
    
    /// Создает набор свайп-действий.
    /// - Parameters:
    ///   - onDelete: Запрос подтверждения удаления без немедленного удаления строки (опционально).
    ///   - onEdit: Действие при редактировании (опционально).
    ///   - onCopy: Копирование в крайней левой позиции при свайпе справа (опционально).
    init(
        onDelete: (() -> Void)? = nil,
        onEdit: (() -> Void)? = nil,
        onCopy: (() -> Void)? = nil
    ) {
        self.onDelete = onDelete
        self.onEdit = onEdit
        self.onCopy = onCopy
    }
    
    // MARK: - Тело View
    
    var body: some View {
        Group {
            if let onDelete {
                Button {
                    haptics.trigger(.warning)
                    onDelete()
                } label: {
                    Label(.delete, systemImage: "trash")
                }
                .tint(.red)
            }
            if let onEdit {
                Button {
                    haptics.trigger(.tap)
                    onEdit()
                } label: {
                    Label(.edit, systemImage: "pencil")
                }
                .tint(.positive)
            }
            if let onCopy {
                Button {
                    haptics.trigger(.tap)
                    onCopy()
                } label: {
                    Label(.expenseCopyAction, systemImage: "doc.on.doc")
                }
                .tint(.accentColor)
            }
        }
    }
}

// MARK: - Превью

#Preview {
    let builder = PreviewBuilder.builder().withLocations(false)
    let data = builder.buildData()
    let trip = builder.getTrip(from: data)
    
    return List {
        TripRowView(trip)
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                SwipeActions(onDelete: {}, onEdit: {})
            }
        TripRowView(trip)
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                SwipeActions(onDelete: {})
            }
        TripRowView(trip)
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                SwipeActions(onEdit: {})
            }
    }
}

