//
//  RootContainerView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI
import SwiftData

struct RootContainerView: View {
    // MARK: - Stored Properties

    @Environment(\.modelContext) private var context

    @State private var settingsStore: AppSettingsStore?
    @State private var hasLoadedSettings = false

    // MARK: - Body

    var body: some View {
        Group {
            if let settingsStore {
                RootTabView()
                    .environment(settingsStore)
                    .preferredColorScheme(settingsStore.appAppearance.colorScheme)
            } else {
                ProgressView()
            }
        }
        .task {
            guard !hasLoadedSettings else { return }
            hasLoadedSettings = true
            settingsStore = AppSettingsStore(context: context)
        }
    }
}
