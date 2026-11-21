//
//  AppUpdateManager.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 21.11.2026.
//

import Foundation
import Observation

/// Проверка обновлений с ограничением частоты и повторным показом после закрытия уведомления.
@MainActor
@Observable
final class AppUpdateManager {
    // MARK: - Хранение состояния

    private enum Keys {
        static let lastCheckDate = "appUpdate.lastCheckDate"
    }

    private(set) var availableUpdate: AppUpdateInfo?

    // MARK: - Зависимости

    private let service: AppUpdateService
    private let defaults: UserDefaults
    private let installedRelease: AppReleaseVersion?
    private let checkInterval: TimeInterval
    private let now: () -> Date
    private let isEnabled: Bool
    private var isChecking = false

    // MARK: - Инициализация

    /// Создает состояние проверки, изолируемое от сети и настроек приложения в тестах.
    /// - Parameters:
    ///   - service: Сервис получения конфигурации; по умолчанию используется рабочая сеть.
    ///   - defaults: Хранилище времени проверки.
    ///   - version: Установленная пользовательская версия; по умолчанию берется из AppInfo.
    ///   - build: Установленный номер сборки; по умолчанию берется из AppInfo.
    ///   - checkInterval: Интервал между завершенными попытками в секундах; по умолчанию берется из конфигурации.
    ///   - now: Источник текущего времени.
    ///   - isEnabled: Разрешение проверки; по умолчанию отключено в SwiftUI previews.
    init(
        service: AppUpdateService? = nil,
        defaults: UserDefaults = .standard,
        version: String? = nil,
        build: String? = nil,
        checkInterval: TimeInterval? = nil,
        now: @escaping () -> Date = { Date() },
        isEnabled: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1"
    ) {
        self.service = service ?? AppUpdateService()
        self.defaults = defaults
        installedRelease = AppReleaseVersion(version: version ?? AppInfo.version, build: build ?? AppInfo.build)
        self.checkInterval = max(0, checkInterval ?? AppUpdateConfig.checkInterval)
        self.now = now
        self.isEnabled = isEnabled
    }

    // MARK: - Публичные методы

    func checkIfNeeded() async {
        guard isEnabled, !isChecking, !Task.isCancelled, let installedRelease else { return }
        let checkDate = now()
        if let lastCheckDate = defaults.object(forKey: Keys.lastCheckDate) as? Date {
            let elapsed = checkDate.timeIntervalSince(lastCheckDate)
            if elapsed >= 0 && elapsed < checkInterval { return }
        }

        isChecking = true
        availableUpdate = nil
        defer { isChecking = false }

        do {
            let info = try await service.fetchUpdate()
            try Task.checkCancellation()
            defaults.set(now(), forKey: Keys.lastCheckDate)

            guard info.notificationEnabled,
                  let release = info.release,
                  release.isNewer(than: installedRelease) else { return }
            availableUpdate = info
        } catch {
            guard !Task.isCancelled, (error as? URLError)?.code != .cancelled else { return }
            defaults.set(now(), forKey: Keys.lastCheckDate)
        }
    }

    func dismissUpdate() {
        availableUpdate = nil
    }
}
