//
//  DotDivider.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.11.2026.
//

import SwiftUI

/// Круглая точка-разделитель.
struct DotDivider: View {
    // MARK: - Свойства
    
    private let font: Font
    private let color: Color
    
    // MARK: - Инициализация
    
    /// Создает точку-разделитель.
    /// - Parameters:
    ///   - font: Шрифт текста. По умолчанию `.body`.
    ///   - color: Цвет текста. По умолчанию `.secondary`.
    init(font: Font = .body, color: Color = .secondary) {
        self.font = font
        self.color = color
    }
    
    // MARK: - Тело View
    
    var body: some View {
        Text("•").font(font).foregroundStyle(color)
    }
}

// MARK: - Предопределенные варианты

extension DotDivider {
    static func secondarySmall() -> some View {
        DotDivider(font: .footnote)
    }
}

// MARK: - Превью

#Preview {
    VStack(spacing: 20) {
        DotDivider()
        DotDivider.secondarySmall()
    }
}
