//
//  LabelView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

struct LabelView: View {
    // MARK: - Свойства
    
    let title: LocalizedStringResource
    let badgeFrameWidth: Double
    let badgeIcon: String?
    let badgeText: String?
    
    // MARK: - Инициализация
    
    init(title: LocalizedStringResource, icon: String, iconFrameWidth: Double = 24) {
        self.title = title
        self.badgeFrameWidth = iconFrameWidth
        self.badgeIcon = icon
        self.badgeText = nil
    }
    
    init(title: LocalizedStringResource, badge: String, badgeFrameWidth: Double = 24) {
        self.title = title
        self.badgeFrameWidth = badgeFrameWidth
        self.badgeIcon = nil
        self.badgeText = badge
    }
    
    // MARK: - Тело View
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            Group {
                if let badgeIcon {
                    Image(systemName: badgeIcon)
                } else if let badgeText {
                    Text(badgeText)
                }
            }
            .foregroundStyle(.secondary)
            .frame(width: badgeFrameWidth)
            Text(title)
        }
    }
}
