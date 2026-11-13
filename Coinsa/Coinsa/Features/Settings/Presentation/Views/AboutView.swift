//
//  AboutView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 11.04.2026.
//

import SwiftUI

/// Экран "О приложении" с информацией о версии, сторонних API и копирайте.
struct AboutView: View {
    // MARK: - Константы

    private enum Layout {
        /// Интервал между строками и элементами шапки сведений о приложении.
        static let headerSpacing: CGFloat = 4
        /// Вертикальные отступы шапки сведений о приложении.
        static let headerVerticalInset: CGFloat = 32
    }

    // MARK: - Вычисляемые свойства
    
    private var privacyPolicyURL: URL {
        let languageCode = Locale.current.language.languageCode?.identifier
        let slug = languageCode == "ru" ? "privacy-ru" : "privacy-en"
        return URL(string: "https://fullentropppy.github.io/coinsa/\(slug).html")!
    }
    
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
            LinkView(
                name: .settingsProjectTitle,
                description: .settingsProjectDescription,
                url: URL(string: "https://github.com/fullentropppy/coinsa")!
            )
            LinkView(
                name: .settingsPrivacyPolicyTitle,
                description: .settingsPrivacyPolicyDescription,
                url: privacyPolicyURL
            )
        }
    }
    
    private var thirdPartyAPISection: some View {
        Section(.settingsThirdPartyAPIs) {
            LinkView(
                name: .thirdPartyHexarate,
                description: .thirdPartyHexarateDescription,
                url: URL(string: "https://hexarate.paikama.co")!
            )
        }
    }
    
    // MARK: - Компоненты
    
    private var appInfoFooter: some View {
        VStack(alignment: .center, spacing: Layout.headerSpacing) {
            Text(AppInfo.appName)
                .font(.footnote)
            HStack(spacing: Layout.headerSpacing) {
                Text(AppInfo.copyrightYears)
                Text(.appAuthor)
            }
            .font(.footnote)
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, Layout.headerVerticalInset)
    }
}

// MARK: - Превью

#Preview {
    AboutView()
}
