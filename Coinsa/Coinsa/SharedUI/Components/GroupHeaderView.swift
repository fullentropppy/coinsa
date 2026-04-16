//
//  GroupHeaderView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 10.04.2026.
//

import SwiftUI

struct GroupHeaderView: View {
    // MARK: Свойства
    
    let icon: String
    let title: LocalizedStringResource
    
    // MARK: Тело View
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .imageScale(.small)
            Text(title)
        }
        .fontWeight(.semibold)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: - Превью

private extension GroupHeaderView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        GroupHeaderView(icon: Location.primaryIcon, title: .tripLocations)
            .environment(\.locale, locale)
            .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    GroupHeaderView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    GroupHeaderView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
