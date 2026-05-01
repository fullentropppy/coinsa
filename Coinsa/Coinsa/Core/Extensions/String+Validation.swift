//
//  String+Validation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.04.2026.
//

/// Проверки строковых значений.
extension String {
    /// Признак того, что строка является пустой или состоящей только из пробелов и символов новой строки.
    var isBlank: Bool {
        self.trimmed.isEmpty
    }
}
