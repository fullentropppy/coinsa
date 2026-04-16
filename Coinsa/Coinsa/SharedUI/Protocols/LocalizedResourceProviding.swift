//
//  LocalizedResourceProviding.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import Foundation

// MARK: - Протокол

protocol LocalizedResourceProviding {
    var localizedResource: LocalizedStringResource { get }
    var localizedResourcePlural: LocalizedStringResource? { get }
}

// MARK: - Стандартная реализация

extension LocalizedResourceProviding {
    // MARK: - Свойства со значениями по умолчанию
    
    var localizedResourcePlural: LocalizedStringResource? { nil }
    
    // MARK: - Свойства с безопасным извлечением
    
    var safeLocalizedResourcePlural: LocalizedStringResource { localizedResourcePlural ?? "" }
}
