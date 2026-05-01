//
//  LabelProviding.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

// MARK: - Протокол

/// Протокол для объектов, которые могут предоставлять стилизованную метку.
protocol LabelProviding {
    // MARK: - Свойства
    
    /// Стиль метки для отображения.
    var labelSyle: LabelView.Style { get }
    
    // MARK: - Методы
    
    /// Создаёт представление метки.
    /// - Returns: Настроенное представление `LabelView`.
    func makeLabel() -> LabelView
}

// MARK: - Стандартная реализация

extension LabelProviding {
    /// Создаёт метку на основе свойства `labelSyle`.
    func makeLabel() -> LabelView {
        LabelView(style: labelSyle)
    }
}
