//
//  AppInfo.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 31.03.2026.
//

import Foundation

/// Централизованное хранение информации о приложении.
struct AppInfo {
    // MARK: - Правовая информация
    
    /// Первый год, поддерживаемый приложением (начало копирайта).
    private static var firstSupportedYear: Int { 2026 }
    
    /// Последний год, поддерживаемый приложением (окончание копирайта).
    private static var lastSupportedYear: Int { 2026 }
    
    /// Строка с копирайтом в формате "© Год" или "© Год-Год".
    static var copyrightYears: String {
        if firstSupportedYear == lastSupportedYear {
            "© \(lastSupportedYear)"
        } else {
            "© \(firstSupportedYear)-\(lastSupportedYear)"
        }
    }
    
    // MARK: - Информация о приложении
    
    /// Отображаемое имя приложения из Info.plist.
    static var appName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Coinsa"
    }
    
    /// Версия приложения (пользовательская версия).
    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "None"
    }
    
    /// Номер сборки приложения (техническая версия).
    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "None"
    }
    
    // MARK: - Параметры сборки
    
    /// Идентификатор iCloud контейнера для текущей схемы сборки.
    static var iCloudContainerIdentifier: String {
#if DEBUG
        "iCloud.ru.dgritsenko.Coinsa.debug"
#else
        "iCloud.ru.dgritsenko.Coinsa"
#endif
    }
}
