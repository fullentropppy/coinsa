//
//  GroupHeaderView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 10.04.2026.
//

import SwiftUI

struct GroupHeaderView: View {
    // MARK: Stored Properties
    
    let title: LocalizedStringResource
    let icon: String
    
    // MARK: Body
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
        }
        .fontWeight(.semibold)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

private extension GroupHeaderView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        GroupHeaderView(title: .tripLocations, icon: Location.primaryIcon)
            .environment(\.locale, locale)
            .preferredColorScheme(colorScheme)
    }
}

// MARK: - Previews

#Preview("Light - RU") {
    GroupHeaderView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    GroupHeaderView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
