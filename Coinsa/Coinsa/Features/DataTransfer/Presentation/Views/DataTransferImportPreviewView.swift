//
//  DataTransferImportPreviewView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.11.2026.
//

import SwiftUI
import SwiftData

/// Модальная проверка импорта с сохранением сводки до завершения анимации закрытия.
struct DataTransferImportPreviewView: View {
    // MARK: - Окружение

    @Environment(\.modelContext) private var context
    @Environment(\.haptics) private var haptics

    // MARK: - Состояние

    @Bindable var viewModel: DataTransferViewModel

    // MARK: - Тело View

    var body: some View {
        NavigationStack {
            Form {
                if let plan = viewModel.plan {
                    previewSections(plan)
                }
            }
            .navigationTitle(.dataTransferPreviewNavigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .disabled(viewModel.isWorking)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ToolbarButton.close {
                        viewModel.closeImportPreview()
                    }
                    .disabled(viewModel.isWorking)
                }
            }
            .notificationAlert(
                isPresented: $viewModel.isShowingNotice,
                title: viewModel.noticeTitle,
                message: viewModel.noticeMessage,
                isError: viewModel.noticeIsError
            )
        }
        .interactiveDismissDisabled(true)
    }

    // MARK: - Сводка

    /// Показывает рассчитанные изменения и подтверждение без записи данных до нажатия кнопки импорта.
    /// - Parameter plan: Проверенный план добавления, обновления и пропуска записей.
    @ViewBuilder
    private func previewSections(_ plan: DataTransferPlan) -> some View {
        Section {
            LabeledContent {
                Text(DateDisplayFormatter.format(plan.source.exportedAt, showsTime: true))
            } label: {
                HStack {
                    AppIcon(AppSymbols.calendar, style: .formLabel)
                    Text(.dataTransferPreviewExportedAt)
                }
            }
        }
        Section(.dataTransferPreviewAdditions) {
            LabeledContent {
                Text(plan.trips.additions.count.formatted())
            } label: {
                HStack {
                    AppIcon(Trip.primaryIcon, style: .formLabel)
                    Text(.dataTransferPreviewTrips)
                }
            }
            LabeledContent {
                Text(plan.locations.additions.count.formatted())
            } label: {
                HStack {
                    AppIcon(Location.primaryIcon, style: .formLabel)
                    Text(.dataTransferPreviewLocations)
                }
            }
            LabeledContent {
                Text(plan.expenses.additions.count.formatted())
            } label: {
                HStack {
                    AppIcon(Expense.primaryIcon, style: .formLabel)
                    Text(.dataTransferPreviewExpenses)
                }
            }
        }
        Section(.dataTransferPreviewUpdates) {
            LabeledContent {
                Text(plan.trips.updates.count.formatted())
            } label: {
                HStack {
                    AppIcon(Trip.primaryIcon, style: .formLabel)
                    Text(.dataTransferPreviewTrips)
                }
            }
            LabeledContent {
                Text(plan.locations.updates.count.formatted())
            } label: {
                HStack {
                    AppIcon(Location.primaryIcon, style: .formLabel)
                    Text(.dataTransferPreviewLocations)
                }
            }
            LabeledContent {
                Text(plan.expenses.updates.count.formatted())
            } label: {
                HStack {
                    AppIcon(Expense.primaryIcon, style: .formLabel)
                    Text(.dataTransferPreviewExpenses)
                }
            }
        }
        Section {
            LabeledContent {
                Text(plan.unchangedCount.formatted())
            } label: {
                HStack {
                    AppIcon(AppSymbols.equal, style: .formLabel)
                    Text(.dataTransferPreviewUnchanged)
                }
            }
            LabeledContent {
                Text(plan.olderCount.formatted())
            } label: {
                HStack {
                    AppIcon(AppSymbols.clock, style: .formLabel)
                    Text(.dataTransferPreviewOlder)
                }
            }
        }
        Section {
            Button {
                haptics.trigger(.tap)
                viewModel.confirmImport(container: context.container)
            } label: {
                HStack {
                    Image(systemName: AppSymbols.squareAndArrowDown)
                        .padding(.bottom, ViewLayout.Label.arrowIconBottomInset)
                    Text(.dataTransferImport)
                }
            }
            .disabled(!plan.hasChanges)
        } footer: {
            Text(.dataTransferPreviewHint)
        }
    }
}

// MARK: - Превью

#Preview {
    @Previewable @State var preview = PreviewEnvironment(
        trips: PreviewBuilder.builder().withScenario(.all).buildData()
    )
    @Previewable @State var viewModel = DataTransferViewModel()

    DataTransferImportPreviewView(viewModel: viewModel)
        .modelContainer(preview.container)
        .environment(preview.settingsStore)
        .task {
            do {
                let repository = DataTransferRepository(container: preview.container)
                viewModel.plan = try repository.prepare(repository.snapshot())
            } catch {
                assertionFailure("Failed to prepare import preview: \(error)")
            }
        }
}
