//
//  ExpenseDestinationView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.11.2026.
//

import SwiftUI
import SwiftData

/// Общий выбор назначения для копирования и переноса траты в пределах поездки.
struct ExpenseDestinationView: View {
    // MARK: - Окружение

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.haptics) private var haptics

    // MARK: - Состояние

    @State private var viewModel: ExpenseDestinationViewModel
    @State private var didSaveExpense = false

    // MARK: - Инициализация

    /// Создает экран выбора назначения существующей траты.
    /// - Parameters:
    ///   - source: Исходная трата текущей поездки.
    ///   - mode: Копирование или перенос с подтверждением в редакторе.
    init(source: Expense, mode: ExpenseDestinationViewModel.Mode = .copy) {
        _viewModel = State(initialValue: ExpenseDestinationViewModel(source: source, mode: mode))
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
                .navigationTitle(Text(viewModel.navigationTitle))
                .navigationSubtitle(viewModel.sourceTrip?.screenContextSubtitle ?? "")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        ToolbarButton.close { dismiss() }
                    }
                }
                .notificationAlert(
                    isPresented: errorBinding,
                    title: viewModel.errorTitle,
                    message: viewModel.errorMessage ?? .errorUnknownMessage,
                    isError: true
                )
        }
        .sheet(item: $viewModel.draft, onDismiss: handleEditorDismiss) { draft in
            ExpenseEditorView(initialViewModel: draft, onSave: { didSaveExpense = true })
        }
    }

    // MARK: - Секции

    @ViewBuilder
    private var locationList: some View {
        if let trip = viewModel.sourceTrip {
            List {
                Section {
                    ExpenseRowView(viewModel.source)
                } header: {
                    Text(viewModel.sourceTitle)
                } footer: {
                    Text(viewModel.hint)
                }

                if viewModel.showsGeneralExpenses {
                    Section {
                        Button {
                            haptics.trigger(.tap)
                            viewModel.selectGeneralExpenses(in: context)
                        } label: {
                            TripRowView(trip)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    } header: {
                        Text(.tripGeneralExpenses)
                    }
                }

                let groups = viewModel.groupedLocations
                if !groups.isEmpty {
                    LocationDestinationSections(groups: groups, title: .expenseDestinationLocations) { location in
                        haptics.trigger(.tap)
                        viewModel.select(location, in: context)
                    }
                }
            }
        } else {
            ContentUnavailableView {
                Label {
                    Text(.expenseEditorUnavailableTitle)
                } icon: {
                    Image(systemName: AppSymbols.exclamationmarkTriangle)
                }
            } description: {
                Text(.expenseEditorUnavailableMessage)
            }
        }
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
        if didSaveExpense {
            dismiss()
        }
    }
}

// MARK: - Превью

#Preview("Editing") {
    @Previewable @State var preview = ExpenseFormPreviewData(isEditing: true)

    if let expense = preview.viewModel?.expense {
        ExpenseDestinationView(source: expense)
            .modelContainer(preview.container)
            .environment(preview.settingsStore)
    }
}

#Preview("Creating") {
    @Previewable @State var preview = TripPreviewData(.asia, includeLocations: true, includeExpenses: true)

    if let expense = preview.trip.locations?.first?.expenses?.first {
        ExpenseDestinationView(source: expense)
            .modelContainer(preview.container)
            .environment(preview.settingsStore)
    }
}

#Preview("Moving") {
    @Previewable @State var preview = ExpenseFormPreviewData(isEditing: true)

    if let expense = preview.viewModel?.expense {
        ExpenseDestinationView(source: expense, mode: .move)
            .modelContainer(preview.container)
            .environment(preview.settingsStore)
    }
}
