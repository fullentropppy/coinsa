//
//  SwipeActions.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 10.04.2026.
//

import SwiftUI

struct SwipeActions: View {
    // MARK: - Свойства
    
    private let onDelete: (() -> Void)?
    private let onEdit: (() -> Void)?
    
    // MARK: - Инициализация
    
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
                        onDelete()
                    } label: {
                        Label(.delete, systemImage: "trash")
                    }
                    .tint(.red)
                }
                if let onEdit {
                    Button {
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

