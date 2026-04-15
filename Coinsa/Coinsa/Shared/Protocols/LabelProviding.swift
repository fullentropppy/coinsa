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
    var labelBadgeFrameWidth: Double { get }
    var labelBadgeIcon: String? { get }
    var labelBadgeText: String? { get }
    
    // MARK: - Методы
    
    func makeLabel() -> LabelView
}

// MARK: - Стандартная реализация

extension LabelProviding {
    // MARK: - Свойства со значениями по умолчанию
    
    var labelBadgeFrameWidth: Double { 28 }
    var labelBadgeIcon: String? { nil }
    var labelBadgeText: String? { nil }
    
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
