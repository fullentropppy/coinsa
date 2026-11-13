//
//  PrimaryAddButton.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 31.03.2026.
//

import SwiftUI

/// Главная кнопка добавления.
struct PrimaryAddButton: View {
    // MARK: - Константы

    private enum Layout {
        /// Радиус цветного свечения иконки добавления.
        static let iconShadowRadius: CGFloat = 12
    }

    // MARK: - Окружение
    
    @Environment(\.haptics) private var haptics
    
    // MARK: - Свойства
    
    let isOnLeft: Bool
    let action: () -> Void
    
    // MARK: - Тело View
    
    var body: some View {
        HStack {
            if !isOnLeft {
                Spacer()
            }
            
            Button {
                haptics.trigger(.add)
                action()
            } label: {
                Image(systemName: "plus")
                    .font(.title)
                    .shadow(color: .accent, radius: Layout.iconShadowRadius)
            }
            .padding(ViewLayout.FloatingControls.buttonInset)
            .contentShape(Circle())
            .glassEffect(.regular.interactive(), in: .circle)
            
            if isOnLeft {
                Spacer()
            }
        }
        .padding(.horizontal, ViewLayout.FloatingControls.edgeInset)
        .padding(.bottom, ViewLayout.FloatingControls.edgeInset)
    }
}

// MARK: - Превью

#Preview {
    HStack {
        PrimaryAddButton(isOnLeft: true) {}
        PrimaryAddButton(isOnLeft: false) {}
    }
}
