//
//  String+Manipulation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.04.2026.
//

import Foundation

/// Манипуляции со строками.
extension String {
    /// Cтрока с удаленными пробелами и символами новой строки в начале и конце.
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
