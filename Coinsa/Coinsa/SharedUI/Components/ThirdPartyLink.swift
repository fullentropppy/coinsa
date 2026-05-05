//
//  ThirdPartyLink.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 11.04.2026.
//

import SwiftUI

/// Элемент текстом и описанием web-ссылки.
struct LinkView: View {
    // MARK: - Свойства
    
    let name: LocalizedStringResource
    let description: LocalizedStringResource
    let url: URL
    
    // MARK: - Тело View
    
    var body: some View {
        Link(destination: url) {
            HStack {
                VStack(alignment: .leading) {
                    Text(name)
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .tint(.primary)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .imageScale(.small)
                    .fontWeight(.semibold)
                    .foregroundStyle(.link)
            }
        }
    }
}

// MARK: - Превью

private extension LinkView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        return List {
            LinkView(
                name: .thirdPartyHexarate,
                description: .thirdPartyHexarateDescription,
                url: URL(string: "example.com")!
            )
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    LinkView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    LinkView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
