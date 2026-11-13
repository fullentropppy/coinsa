//
//  ToolbarButton.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI

/// Кнопка для использования в панелях инструментов.
struct ToolbarButton: View {
    // MARK: - Окружение
    
    @Environment(\.haptics) private var haptics
    
    // MARK: - Свойства
    
    private let title: LocalizedStringResource?
    private let icon: String
    private let action: () -> Void
    private let hapticType: HapticType?
    
    // MARK: - Инициализация
    
    /// Создает кнопку панели инструментов с иконкой, действием и необязательным тактильным откликом.
    private init(
        title: LocalizedStringResource? = nil,
        icon: String,
        action: @escaping () -> Void,
        hapticType: HapticType? = nil
    ) {
        self.title = title
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
            if let title {
                Label(title, systemImage: icon)
            } else {
                Image(systemName: icon)
            }
        }
    }
}

// MARK: - Предопределенные варианты

extension ToolbarButton {
    /// Кнопка "ОК" (галочка) с тактильным откликом `.tap`.
    static func ok(showsTitle: Bool = false, action: @escaping () -> Void) -> some View {
        let title: LocalizedStringResource? = showsTitle ? .ok : nil
        return ToolbarButton(title: title, icon: "checkmark", action: action, hapticType: .tap)
    }
    
    /// Кнопка добавления (плюс) с тактильным откликом `.add`.
    static func add(showsTitle: Bool = false, action: @escaping () -> Void) -> some View {
        let title: LocalizedStringResource? = showsTitle ? .add : nil
        return ToolbarButton(title: title, icon: "plus", action: action, hapticType: .add)
    }
    
    /// Кнопка редактирования (карандаш) с тактильным откликом `.tap`.
    static func edit(showsTitle: Bool = false, action: @escaping () -> Void) -> some View {
        let title: LocalizedStringResource? = showsTitle ? .edit : nil
        return ToolbarButton(title: title, icon: "pencil", action: action, hapticType: .tap)
    }
    
    /// Кнопка удаления (корзина) с тактильным откликом `.warning`.
    static func delete(showsTitle: Bool = false, action: @escaping () -> Void) -> some View {
        let title: LocalizedStringResource? = showsTitle ? .delete : nil
        return ToolbarButton(title: title, icon: "trash", action: action, hapticType: .warning)
    }
    
    /// Кнопка закрытия (крестик) без тактильного отклика.
    static func close(showsTitle: Bool = false, action: @escaping () -> Void) -> some View {
        let title: LocalizedStringResource? = showsTitle ? .close : nil
        return ToolbarButton(title: title, icon: "xmark", action: action)
    }
        
    /// Кнопка настроек (шестеренка) без тактильного отклика.
    static func settings(showsTitle: Bool = false, action: @escaping () -> Void) -> some View {
        let title: LocalizedStringResource? = showsTitle ? .settings : nil
        return ToolbarButton(title: title, icon: "gear", action: action)
    }
}

// MARK: - Превью

#Preview {
    VStack(spacing: 20) {
        ToolbarButton.ok {}
        ToolbarButton.add {}
        ToolbarButton.edit {}
        ToolbarButton.delete {}
        ToolbarButton.close {}
        ToolbarButton.settings {}
    }
}
