//
//  RootContainerView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI

/// Корневой контейнер загрузки настроек, сплеш-экрана и уведомления об обновлении.
struct RootContainerView: View {
    // MARK: - Окружение

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.locale) private var locale

    // MARK: - Свойства
    
    @State private var settingsStore: AppSettingsStore?
    @State private var showsLaunchContinuation = true
    @State private var updateManager = AppUpdateManager()

    // MARK: - Вычисляемые свойства

    private var canCheckForUpdates: Bool {
        scenePhase == .active && settingsStore != nil && !showsLaunchContinuation
    }

    private var updatePresentation: Binding<Bool> {
        Binding(
            get: { canCheckForUpdates && updateManager.availableUpdate != nil },
            set: { if !$0 { updateManager.dismissUpdate() } }
        )
    }

    private var updateMessage: LocalizedStringResource? {
        guard let info = updateManager.availableUpdate else { return nil }
        let releaseNotes = info.localizedReleaseNotes(locale: locale)

        if releaseNotes.isEmpty {
            return .appUpdateAvailableMessage(
                newVersion: info.latestVersion,
                newBuild: info.latestBuild,
                currentVersion: AppInfo.version,
                currentBuild: AppInfo.build
            )
        }
        return .appUpdateAvailableMessageWithNotes(
            newVersion: info.latestVersion,
            newBuild: info.latestBuild,
            currentVersion: AppInfo.version,
            currentBuild: AppInfo.build,
            releaseNotes: releaseNotes
        )
    }

    // MARK: - Тело View
    
    var body: some View {
        ZStack {
            if let settingsStore {
                RootTabView()
                    .environment(settingsStore)
                    .environment(\.haptics, .live)
                    .preferredColorScheme(settingsStore.appAppearance.colorScheme)
            } else {
                ProgressView()
                    .task {
                        if settingsStore == nil {
                            settingsStore = AppSettingsStore()
                        }
                    }
            }
            if showsLaunchContinuation {
                SplashView {
                    showsLaunchContinuation = false
                }
                .transition(.opacity)
            }
        }
        .task(id: canCheckForUpdates) {
            if canCheckForUpdates {
                await updateManager.checkIfNeeded()
            }
        }
        .notificationAlert(
            isPresented: updatePresentation,
            title: .appUpdateAvailableTitle,
            message: updateMessage ?? .appUpdateAvailableTitle
        )
    }
}
