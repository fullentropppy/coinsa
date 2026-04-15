//
//  PreviewWrapper.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

struct PreviewWrapper<Content: View>: View {
    // MARK: - Свойства
    
    let colorScheme: ColorScheme
    let locale: Locale
    let content: () -> Content
    
    // MARK: - Инициализация
    
    init(
        colorScheme: ColorScheme,
        locale: Locale = .current,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.colorScheme = colorScheme
        self.locale = locale
        self.content = content
    }
    
    // MARK: - Тело View
    
    var body: some View {
        content()
            .environment(\.locale, locale)
            .preferredColorScheme(colorScheme)
            .padding()
    }
}
