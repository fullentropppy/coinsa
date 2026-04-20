//
//  LabelProviding.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

// MARK: - Протокол

protocol LabelProviding {
    // MARK: - Свойства
    
    var labelSyle: LabelView.Style { get }
    
    // MARK: - Методы
    
    func makeLabel() -> LabelView
}

// MARK: - Стандартная реализация

extension LabelProviding {
    func makeLabel() -> LabelView {
        LabelView(style: labelSyle)
    }
}
