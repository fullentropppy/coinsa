//
//  LabeledHeader.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 10.04.2026.
//

import SwiftUI

struct LabeledHeader: View {
    // MARK: Свойства
    
    let title: LocalizedStringResource
    let icon: String
    
    // MARK: Тело View
    
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

// MARK: - Превью

private extension LabeledHeader {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        LabeledHeader(title: .tripLocations, icon: Location.primaryIcon)
            .environment(\.locale, locale)
            .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    LabeledHeader.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    LabeledHeader.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
