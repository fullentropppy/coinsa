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
    
    var labelTitle: LocalizedStringResource { get }
    var labelBadgeIcon: String? { get }
    var labelBadgeText: String? { get }
    var labelBadgeFrameWidth: Double { get }
    
    // MARK: - Методы
    
    func makeLabel() -> LabelView
}

// MARK: - Стандартная реализация

extension LabelProviding {
    // MARK: - Свойства со значениями по умолчанию
    
    var labelBadgeIcon: String? { nil }
    var labelBadgeText: String? { nil }
    var labelBadgeFrameWidth: Double { 24 }
    
    // MARK: - Свойства с безопасным извлечением
    
    var safeLabelBadgeIcon: String { labelBadgeIcon ?? "" }
    var safelabelBadgeText: String { labelBadgeText ?? "" }
    
    // MARK: - Методы
    
    func makeLabel() -> LabelView {
        LabelView(
            title: labelTitle,
            badgeFrameWidth: labelBadgeFrameWidth,
            badgeIcon: labelBadgeIcon,
            badgeText: labelBadgeText
        )
    }
}
