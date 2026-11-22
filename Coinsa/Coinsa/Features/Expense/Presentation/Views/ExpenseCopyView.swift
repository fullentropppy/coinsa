//
//  ExpenseCopyView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 22.11.2026.
//

import SwiftUI
import SwiftData

/// Выбор локации текущей поездки с переходом к черновику копии траты.
struct ExpenseCopyView: View {
    // MARK: - Окружение

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.haptics) private var haptics

    // MARK: - Состояние

    @State private var viewModel: ExpenseCopyViewModel
    @State private var didSaveCopy = false

    // MARK: - Инициализация

    /// Создает экран копирования существующей траты.
    /// - Parameter source: Трата, данные которой будут перенесены в новый черновик.
    init(source: Expense) {
        _viewModel = State(initialValue: ExpenseCopyViewModel(source: source))
    }

    // MARK: - Тело View

    var body: some View {
        if viewModel.skipsLocationSelection, let draft = viewModel.draft {
            ExpenseEditorView(initialViewModel: draft)
        } else {
            locationSelection
        }
    }

    // MARK: - Выбор локации

    private var locationSelection: some View {
        NavigationStack {
            locationList
                .navigationTitle(Text(.expenseCopyNavigationTitle))
                .navigationSubtitle(viewModel.sourceLocation?.trip?.screenContextSubtitle ?? "")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        ToolbarButton.close { dismiss() }
                    }
                }
                .notificationAlert(
                    isPresented: errorBinding,
                    title: .expenseStorageErrorTitle,
                    message: viewModel.errorMessage ?? .errorUnknownMessage,
                    isError: true
                )
        }
        .sheet(item: $viewModel.draft, onDismiss: handleEditorDismiss) { draft in
            ExpenseEditorView(initialViewModel: draft, onSave: { didSaveCopy = true })
        }
    }

    // MARK: - Секции

    @ViewBuilder
    private var locationList: some View {
        if let sourceLocation = viewModel.sourceLocation {
            List {
                Section {
                    locationButton(sourceLocation)
                } header: {
                    Text(.expenseCopyCurrentLocation)
                } footer: {
                    Text(.expenseCopyHint)
                }

                let groups = viewModel.groupedLocations
                GroupHeader(
                    icon: Location.primaryIcon,
                    title: .expenseCopyOtherLocations,
                    itemCount: groups.reduce(0) { $0 + $1.locations.count }
                )
                .listRowBackground(Color.clear)

                ForEach(groups, id: \.status) { group in
                    Section(group.status.safeLocalizedResourcePlural) {
                        ForEach(group.locations) { location in
                            locationButton(location)
                        }
                    }
                }
            }
        } else {
            ContentUnavailableView {
                Label {
                    Text(.expenseEditorUnavailableTitle)
                } icon: {
                    Image(systemName: "exclamationmark.triangle")
                }
            } description: {
                Text(.expenseEditorUnavailableMessage)
            }
        }
    }

    private func locationButton(_ location: Location) -> some View {
        Button {
            haptics.trigger(.tap)
            viewModel.select(location, in: context)
        } label: {
            LocationRowView(location)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Биндинги

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }

    // MARK: - Действия

    private func handleEditorDismiss() {
        if didSaveCopy {
            dismiss()
        }
    }
}

// MARK: - Превью

#Preview("Editing") {
    @Previewable @State var preview = ExpenseFormPreviewData(isEditing: true)

    if let expense = preview.viewModel?.expense {
        ExpenseCopyView(source: expense)
            .modelContainer(preview.container)
            .environment(preview.settingsStore)
    }
}

#Preview("Creating") {
    @Previewable @State var preview = TripPreviewData(.asia, includeLocations: true, includeExpenses: true)

    if let expense = preview.trip.locations?.first?.expenses?.first {
        ExpenseCopyView(source: expense)
            .modelContainer(preview.container)
            .environment(preview.settingsStore)
    }
}
