//
//  TripEditorView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

import SwiftUI
import SwiftData

/// Единый вход в создание и редактирование поездки с проверкой доступности исходных данных.
struct TripEditorView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: TripEditViewModel?
    private let onDelete: (() -> Void)?

    /// Создает экран новой поездки.
    /// - Parameter homeCurrency: Домашняя валюта по умолчанию.
    init(forCreateWith homeCurrency: Currency) {
        self.init(initialViewModel: TripEditViewModel(forCreateWith: homeCurrency))
    }

    /// Создает редактор поездки или сообщает о недоступности исходных данных.
    /// - Parameters:
    ///   - trip: Редактируемая поездка.
    ///   - onDelete: Действие после успешного удаления.
    init(forEdit trip: Trip, onDelete: (() -> Void)? = nil) {
        self.init(initialViewModel: TripEditViewModel(forEdit: trip), onDelete: onDelete)
    }

    /// Создает точку входа для подготовленного черновика или состояния недоступности данных.
    /// - Parameters:
    ///   - initialViewModel: Черновик поездки или nil при недоступности исходных данных.
    ///   - onDelete: Действие после успешного удаления.
    init(initialViewModel: TripEditViewModel?, onDelete: (() -> Void)? = nil) {
        _viewModel = State(initialValue: initialViewModel)
        self.onDelete = onDelete
    }

    var body: some View {
        if let viewModel {
            TripEditorContainerView(initialViewModel: viewModel, onDelete: onDelete)
        } else {
            NavigationStack {
                ContentUnavailableView {
                    Label {
                        Text(.tripEditorUnavailableTitle)
                    } icon: {
                        Image(systemName: AppSymbols.exclamationmarkTriangle)
                    }
                } description: {
                    Text(.tripEditorUnavailableMessage)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        ToolbarButton.close { dismiss() }
                    }
                }
            }
        }
    }
}

// MARK: - Превью

#Preview("Editing") {
    @Previewable @State var preview = TripPreviewData()

    TripEditorView(initialViewModel: preview.viewModel)
        .modelContainer(preview.container)
        .environment(preview.settingsStore)
}

#Preview("Creating") {
    @Previewable @State var preview = TripPreviewData(isEditing: false)

    TripEditorView(initialViewModel: preview.viewModel)
        .modelContainer(preview.container)
        .environment(preview.settingsStore)
}
