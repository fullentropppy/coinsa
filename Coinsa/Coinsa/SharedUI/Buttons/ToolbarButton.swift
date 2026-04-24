//
//  ToolbarButton.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI

struct ToolbarButton: View {
    // MARK: - Окружение
    
    @Environment(\.haptics) private var haptics
    
    // MARK: - Свойства
    
    private let icon: String
    private let action: () -> Void
    private let hapticType: HapticType?
    
    // MARK: - Инициализация
    
    private init(icon: String, action: @escaping () -> Void, hapticType: HapticType? = nil) {
        self.icon = icon
        self.action = action
        self.hapticType = hapticType
    }
    
    // MARK: - Тело View
    
    var body: some View {
        Button {
            if let hapticType {
                haptics.trigger(hapticType)
            }
            action()
        } label: {
            Image(systemName: icon)
        }
    }
}

// MARK: - Предопределенные варианты

extension ToolbarButton {
    static func ok(action: @escaping () -> Void) -> some View {
        ToolbarButton(icon: "checkmark", action: action, hapticType: .tap)
    }
    
    static func add(action: @escaping () -> Void) -> some View {
        ToolbarButton(icon: "plus", action: action, hapticType: .add)
    }
    
    static func edit(action: @escaping () -> Void) -> some View {
        ToolbarButton(icon: "pencil", action: action, hapticType: .tap)
    }
    
    static func delete(action: @escaping () -> Void) -> some View {
        ToolbarButton(icon: "trash", action: action, hapticType: .warning)
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

#Preview("Dark") {
    ToolbarButton.makePreview(colorScheme: .dark)
}
