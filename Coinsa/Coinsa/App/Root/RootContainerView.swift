//
//  RootContainerView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI
import SwiftData

struct RootContainerView: View {
    // MARK: - Свойства
    
    @Environment(\.modelContext) private var context
    
    @State private var settingsStore: AppSettingsStore?
    @State private var hasLoadedSettings = false
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
                        if !hasLoadedSettings {
                            settingsStore = AppSettingsStore(context: context)
                            hasLoadedSettings = true
                        }
                    }
            }
            if showsLaunchContinuation {
                SplashView { showsLaunchContinuation = false }
                    .transition(.opacity)
            }
        }
    }
}
