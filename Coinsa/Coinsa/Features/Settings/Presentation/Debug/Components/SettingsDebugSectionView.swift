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
    // MARK: - Окружение
    
    @Environment(\.haptics) private var haptics
    
    // MARK: - Состояние

    @State private var pendingAction: DebugAction?
    @State private var resultMessage: LocalizedStringResource = ""
    @State private var isShowingResultAlert = false

    // MARK: - Зависимости
    
    let demoDataService: DemoDataService
    
    // MARK: - Тело View

    var body: some View {
        settingsDebugSection
            .alert(
                pendingAction?.alertTitle ?? .confirmation,
                isPresented: isShowingConfirmation,
                presenting: pendingAction
            ) { action in
                Button(action.alertConfirm, role: .destructive) {
                    perform(action)
                }
                Button(.cancel, role: .cancel) {}
            } message: { action in
                Text(action.alertMessage)
            }
            .notificationAlert(
                isPresented: $isShowingResultAlert,
                title: "",
                message: resultMessage
            )
    }

    // MARK: - Основной контент
    
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
    
    // MARK: - Биндинги

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

    // MARK: - Действия

    private func requestLoadDemoData() {
        if demoDataService.hasExistingData() {
            haptics.trigger(.warning)
            pendingAction = .loadDemoData
        } else {
            perform(.loadDemoData)
        }
    }

    private func requestDeleteAllData() {
        haptics.trigger(.warning)
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
            resultMessage = .errorMessage(errorDescription: error.localizedDescription)
        }

        isShowingResultAlert = true
    }
}

// MARK: - Приватные типы

private enum DebugAction: String, Identifiable {
    // MARK: - Значения
    
    case loadDemoData
    case deleteAllData
    
    // MARK: - Вычисляемые свойства
    
    var id: String {
        rawValue
    }
    
    var alertTitle: LocalizedStringResource {
        switch self {
        case .loadDemoData: .debugLoadTitle
        case .deleteAllData: .debugDeleteTitle
        }
    }
    
    var alertMessage: LocalizedStringResource {
        switch self {
        case .loadDemoData: .debugLoadMessage
        case .deleteAllData: .debugDeleteMessage
        }
    }
    
    var alertConfirm: LocalizedStringResource {
        switch self {
        case .loadDemoData: .debugLoadConfirm
        case .deleteAllData: .delete
        }
    }
}

// MARK: - Превью

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
    SettingsDebugSectionView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    SettingsDebugSectionView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}

#endif
