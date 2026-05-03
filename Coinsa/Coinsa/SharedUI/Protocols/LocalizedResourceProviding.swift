//
//  LocalizedResourceProviding.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import Foundation

// MARK: - Протокол

/// Протокол для объектов, предоставляющих локализованные строковые ресурсы.
protocol LocalizedResourceProviding {
    /// Локализованный строковый ресурс в единственном числе.
    var localizedResource: LocalizedStringResource { get }
    
    /// Локализованный строковый ресурс во множественном числе (опционально).
    var localizedResourcePlural: LocalizedStringResource? { get }
}

// MARK: - Стандартная реализация

extension LocalizedResourceProviding {
    // MARK: - Свойства со значениями по умолчанию
    
    /// Ресурс во множественном числе. По умолчанию - `nil`.
    var localizedResourcePlural: LocalizedStringResource? { nil }
    
    // MARK: - Свойства с безопасным извлечением
    
    /// Безопасное извлечение ресурса во множественном числе.
    /// Возвращает переданный ресурс или ресурс в единственном числе, если ресурс отсутствует.
    var safeLocalizedResourcePlural: LocalizedStringResource {
        localizedResourcePlural ?? localizedResource }
}
