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
    
    // MARK: - Инициализация
    
    /// Создаёт набор свайп-действий.
    /// - Parameters:
    ///   - onDelete: Действие при удалении (опционально).
    ///   - onEdit: Действие при редактировании (опционально).
    init(
        onDelete: (() -> Void)? = nil,
        onEdit: (() -> Void)? = nil
    ) {
        self.onDelete = onDelete
        self.onEdit = onEdit
    }
    
    // MARK: - Тело View
    
    var body: some View {
        if onDelete == nil && onEdit == nil {
            EmptyView()
        } else {
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
                    .tint(.green)
                }
            }
        }
    }
}

// MARK: - Превью

private extension SwipeActions {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
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
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    SwipeActions.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    SwipeActions.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}

