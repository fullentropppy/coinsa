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
    var labelSyle: ItemLabel.Style { get }
    
    // MARK: - Методы
    
    /// Создает представление метки.
    /// - Returns: Настроенное представление `LabelView`.
    func makeLabel() -> ItemLabel
}

// MARK: - Стандартная реализация

extension LabelProviding {
    /// Создает метку на основе свойства `labelSyle`.
    func makeLabel() -> ItemLabel {
        ItemLabel(style: labelSyle)
    }
}
