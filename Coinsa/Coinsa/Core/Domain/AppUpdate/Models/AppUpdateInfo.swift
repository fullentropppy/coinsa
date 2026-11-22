//
//  AppUpdateInfo.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 21.11.2026.
//

import Foundation

/// Сведения о доступной сборке и разрешении показывать уведомление.
struct AppUpdateInfo: Decodable {
    // MARK: - Свойства

    let schemaVersion: Int
    let channel: String
    let notificationEnabled: Bool
    let latestVersion: String
    let latestBuild: String
    let releaseNotes: [String: String]

    var release: AppReleaseVersion? {
        AppReleaseVersion(version: latestVersion, build: latestBuild)
    }

    var isSupported: Bool {
        schemaVersion == 1 && channel == "testflight" && release != nil
    }

    // MARK: - Методы

    func localizedReleaseNotes(locale: Locale) -> String {
        let language = locale.language.languageCode?.identifier ?? "en"
        for key in [language, "en", "ru"] {
            if let text = releaseNotes[key]?.trimmingCharacters(in: .whitespacesAndNewlines),
               !text.isEmpty {
                return text
            }
        }
        return ""
    }
}
