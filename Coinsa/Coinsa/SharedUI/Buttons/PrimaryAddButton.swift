//
//  PrimaryAddButton.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 31.03.2026.
//

import SwiftUI

/// Главная кнопка добавления.
struct PrimaryAddButton: View {
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
            }
            .padding(16)
            .contentShape(Circle())
            .glassEffect(.regular.interactive(), in: .circle)
            
            if isOnLeft {
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

// MARK: - Превью

private extension PrimaryAddButton {
    static func makePreview(colorScheme: ColorScheme) -> some View {
        HStack {
            PrimaryAddButton(isOnLeft: true) {}
            PrimaryAddButton(isOnLeft: false) {}
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light") {
    PrimaryAddButton.makePreview(colorScheme: .light)
}

#Preview("Dark") {
    PrimaryAddButton.makePreview(colorScheme: .dark)
}
