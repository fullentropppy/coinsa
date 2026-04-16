//
//  ToolbarButton.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI

struct ToolbarButton: View {
    // MARK: - Свойства
    
    private let icon: String
    private let action: () -> Void
    
    // MARK: - Инициализация
    
    private init(icon: String, action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
    }
    
    // MARK: - Тело View
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: icon)
        }
    }
}

// MARK: - Предопределенные варианты

extension ToolbarButton {
    static func ok(action: @escaping () -> Void) -> some View {
        ToolbarButton(icon: "checkmark", action: action)
    }
    
    static func add(action: @escaping () -> Void) -> some View {
        ToolbarButton(icon: "plus", action: action)
    }
    
    static func edit(action: @escaping () -> Void) -> some View {
        ToolbarButton(icon: "pencil", action: action)
    }
    
    static func delete(action: @escaping () -> Void) -> some View {
        ToolbarButton(icon: "trash", action: action)
    }
    
    static func close(action: @escaping () -> Void) -> some View {
        ToolbarButton(icon: "xmark", action: action)
    }
        
    static func settings(action: @escaping () -> Void) -> some View {
        ToolbarButton(icon: "gear", action: action)
    }
}

// MARK: - Превью

private extension ToolbarButton {
    static func makePreview(colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            ToolbarButton.ok {}
            ToolbarButton.add {}
            ToolbarButton.edit {}
            ToolbarButton.delete {}
            ToolbarButton.close {}
            ToolbarButton.settings {}
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light") {
    ToolbarButton.makePreview(colorScheme: .light)
}

#Preview("dark") {
    ToolbarButton.makePreview(colorScheme: .dark)
}
