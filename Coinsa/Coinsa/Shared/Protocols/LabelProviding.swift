//
//  LabelProviding.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

// MARK: - Протокол

protocol LabelProviding {
    var labelTitle: LocalizedStringResource { get }
    var labelBadgeIcon: String? { get }
    var labelBadgeText: String? { get }
    var labelBadgeFrameWidth: Double { get }
}

// MARK: - Стандартная реализация

extension LabelProviding {
    // MARK: - Свойства
    
    var labelBadgeIcon: String? { nil }
    var labelBadgeText: String? { nil }
    var labelBadgeFrameWidth: Double { 24 }
    
    // MARK: - Методы
    
    func makeLabel() -> some View {
        Group {
            if let labelBadgeIcon {
                LabelView(title: labelTitle, icon: labelBadgeIcon, iconFrameWidth: labelBadgeFrameWidth)
            } else if let labelBadgeText {
                LabelView(title: labelTitle, badge: labelBadgeText, badgeFrameWidth: labelBadgeFrameWidth)
            } else {
                EmptyView()
            }
        }
    }
}
