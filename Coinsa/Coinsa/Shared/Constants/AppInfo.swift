//
//  AppInfo.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 31.03.2026.
//

import Foundation

struct AppInfo {
    // MARK: - Правовая информация
    
    private static var firstSupportedYear: Int { 2026 }
    private static var lastSupportedYear: Int { 2026 }
    
    static var copyrightYears: String {
        if firstSupportedYear == lastSupportedYear {
            "© \(lastSupportedYear)"
        } else {
            "© \(firstSupportedYear)-\(lastSupportedYear)"
        }
    }
    
    // MARK: - Информация о приложении
    
    static var appName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Coinsa"
    }

    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "None"
    }

    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "None"
    }
}
