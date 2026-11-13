//
//  ClearButton.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 12.11.2026.
//

import SwiftUI

/// Кнопка очистки содержимого.
struct ClearButton: View {
    // MARK: - Окружение

    @Environment(\.haptics) private var haptics

    // MARK: - Свойства

    let action: () -> Void

    // MARK: - Тело View

    var body: some View {
        Button(role: .destructive) {
            haptics.trigger(.tap)
            action()
        } label: {
            HStack(spacing: ViewLayout.Label.compactIconSpacing) {
                Image(systemName: "xmark.circle.fill")
                    .imageScale(.small)
                Text(.clear)
                    .font(.footnote)
            }
        }
    }
}

// MARK: - Превью

#Preview {
    ClearButton {}
}
