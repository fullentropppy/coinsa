//
//  String+Validation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.04.2026.
//

import Foundation

extension String {
    var isBlank: Bool {
        self.trimmed.isEmpty
    }
}
