//
//  RootContainerView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI

/// Корневой контейнер, управляющий загрузкой настроек и отображением сплеш-экрана.
struct RootContainerView: View {
    // MARK: - Свойства
    
    @State private var settingsStore: AppSettingsStore?
    @State private var showsLaunchContinuation = true

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
    }
}
