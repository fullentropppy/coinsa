//
//  AboutView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 11.04.2026.
//

import SwiftUI

/// Экран "О приложении" с информацией о версии, сторонних API и копирайте.
struct AboutView: View {
    // MARK: - Тело View
    
    var body: some View {
        NavigationStack {
            Form {
                versionSection
                thirdPartyAPISection
            }
            .navigationTitle(.settingsAbout)
            .navigationBarTitleDisplayMode(.large)
            .safeAreaInset(edge: .bottom) {
                appInfoFooter
            }
        }
    }
    
    // MARK: - Секции
    
    private var versionSection: some View {
        Section {
            LabeledContent(.appVersion, value: "\(AppInfo.version) (\(AppInfo.build))")
        }
    }
    
    private var thirdPartyAPISection: some View {
        Section(.settingsThirdPartyAPIs) {
            ThirdPartyLink(
                name: .thirdPartyHexarate,
                description: .thirdPartyHexarateDescription,
                url: URL(string: "https://hexarate.paikama.co")!
            )
        }
    }
    
    // MARK: - Компоненты
    
    private var appInfoFooter: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(AppInfo.appName)
                .font(.footnote)
            HStack(spacing: 4) {
                Text(AppInfo.copyrightYears)
                Text(.appAuthor)
            }
            .font(.footnote)
        }
        .foregroundStyle(.gray)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

// MARK: - Превью

private extension AboutView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        return AboutView()
            .environment(\.locale, locale)
            .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    AboutView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    AboutView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
