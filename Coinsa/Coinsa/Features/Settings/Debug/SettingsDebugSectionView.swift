//
//  SettingsDebugSectionView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.04.2026.
//

#if DEBUG

import SwiftUI
import SwiftData

struct SettingsDebugSectionView: View {
    // MARK: - Stored Properties

    @State private var pendingAction: DebugAction?
    @State private var resultMessage: LocalizedStringResource = ""
    @State private var isShowingResultAlert = false

    let demoDataService: DemoDataService
    
    // MARK: - Body

    var body: some View {
        settingsDebugSection
            .alert(
                .commonConfirmTitle,
                isPresented: isShowingConfirmation,
                presenting: pendingAction
            ) { action in
                Button(action.confirmationTitle, role: .destructive) {
                    perform(action)
                }
                Button(.commonCancel, role: .cancel) {}
            } message: { action in
                Text(action.confirmationMessage)
            }
            .alert(.commonResult, isPresented: $isShowingResultAlert) {
                Button(.commonOk, role: .cancel) {}
            } message: {
                Text(resultMessage)
            }
    }

    // MARK: - Content
    
    private var settingsDebugSection: some View {
        Section {
            Button(.debugLoad) {
                requestLoadDemoData()
            }
            Button(.debugDelete, role: .destructive) {
                requestDeleteAllData()
            }
        } header: {
            HStack {
                Image(systemName: "wrench.and.screwdriver.fill")
                Text(.settingsDebug)
            }
        }
    }
    
    // MARK: - Bindings

    private var isShowingConfirmation: Binding<Bool> {
        Binding(
            get: { pendingAction != nil },
            set: { shouldShow in
                if !shouldShow {
                    pendingAction = nil
                }
            }
        )
    }

    // MARK: - Actions

    private func requestLoadDemoData() {
        if demoDataService.hasExistingData() {
            pendingAction = .loadDemoData
        } else {
            perform(.loadDemoData)
        }
    }

    private func requestDeleteAllData() {
        pendingAction = .deleteAllData
    }

    private func perform(_ action: DebugAction) {
        pendingAction = nil

        do {
            switch action {
            case .loadDemoData:
                try demoDataService.loadDemoData()
                resultMessage = .debugLoadResult
            case .deleteAllData:
                try demoDataService.deleteAllData()
                resultMessage = .debugDeleteResult
            }
        } catch {
            resultMessage = .debugError(errorDescription: error.localizedDescription)
        }

        isShowingResultAlert = true
    }
}

// MARK: - DebugAction

private enum DebugAction: String, Identifiable {
    // MARK: - Cases
    
    case loadDemoData
    case deleteAllData
    
    // MARK: - Computed Properties
    
    var id: String {
        rawValue
    }
    
    var confirmationTitle: LocalizedStringResource {
        switch self {
        case .loadDemoData: .commonConfirmTitle
        case .deleteAllData: .commonConfirmTitle
        }
    }
    
    var confirmationMessage: LocalizedStringResource {
        switch self {
        case .loadDemoData: .debugLoadMessage
        case .deleteAllData: .debugDeleteMessage
        }
    }
}

// MARK: - Previews

private extension SettingsDebugSectionView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let container = PreviewBuilder.builder().withLocations(false).buildContainer()
        let demoDataService = DemoDataService(context: container.mainContext)
        
        return Form {
            SettingsDebugSectionView(demoDataService: demoDataService)
        }
        .modelContainer(container)
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    SettingsDebugSectionView.makePreview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    SettingsDebugSectionView.makePreview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}

#endif
