//
//  LocationEditorView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

import SwiftUI
import SwiftData

/// Единый вход в создание и редактирование локации с проверкой доступности исходных данных.
struct LocationEditorView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: LocationEditViewModel?
    private let onDelete: (() -> Void)?

    /// Создает экран новой локации.
    /// - Parameters:
    ///   - trip: Родительская поездка.
    ///   - preselectedExchangeAdjustment: Предустановленная корректировка курса.
    init(forCreateWith trip: Trip, preselectedExchangeAdjustment: Double? = nil) {
        self.init(initialViewModel: trip.isDeleted ? nil : LocationEditViewModel(
            forCreateWith: trip,
            preselectedExchangeAdjustment: preselectedExchangeAdjustment
        ))
    }

    /// Создает редактор или сообщает о недоступности локации и ее родительской поездки.
    /// - Parameters:
    ///   - location: Редактируемая локация.
    ///   - onDelete: Действие после успешного удаления.
    init(forEdit location: Location, onDelete: (() -> Void)? = nil) {
        self.init(initialViewModel: LocationEditViewModel(forEdit: location), onDelete: onDelete)
    }

    /// Создает точку входа для уже подготовленного черновика или состояния недоступности данных.
    /// - Parameters:
    ///   - initialViewModel: Черновик локации или nil при недоступности исходных данных.
    ///   - onDelete: Действие после успешного удаления.
    init(initialViewModel: LocationEditViewModel?, onDelete: (() -> Void)? = nil) {
        _viewModel = State(initialValue: initialViewModel)
        self.onDelete = onDelete
    }

    var body: some View {
        if let viewModel {
            LocationEditorContainerView(initialViewModel: viewModel, onDelete: onDelete)
        } else {
            NavigationStack {
                ContentUnavailableView {
                    Label {
                        Text(.locationEditorUnavailableTitle)
                    } icon: {
                        Image(systemName: "exclamationmark.triangle")
                    }
                } description: {
                    Text(.locationEditorUnavailableMessage)
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
    @Previewable @State var preview = LocationFormPreviewData(isEditing: true)

    if let viewModel = preview.viewModel {
        LocationEditorView(initialViewModel: viewModel)
            .modelContainer(preview.container)
            .environment(preview.settingsStore)
    }
}

#Preview("Creating") {
    @Previewable @State var preview = LocationFormPreviewData(isEditing: false)

    if let viewModel = preview.viewModel {
        LocationEditorView(initialViewModel: viewModel)
            .modelContainer(preview.container)
            .environment(preview.settingsStore)
    }
}
