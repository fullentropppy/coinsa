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
            .overlay {
                if viewModel.isWorking {
                    ProgressView(.dataTransferImportProgress)
                        .padding(ViewLayout.Card.contentInset)
                        .background(.regularMaterial, in: .rect(cornerRadius: ViewLayout.Card.cornerRadius))
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
            LabeledContent(.dataTransferPreviewExportedAt) {
                Text(DateDisplayFormatter.format(plan.source.exportedAt, showsTime: true))
            }
        }
        Section(.dataTransferPreviewAdditions) {
            LabeledContent(.dataTransferPreviewTrips, value: plan.trips.additions.count.formatted())
            LabeledContent(.dataTransferPreviewLocations, value: plan.locations.additions.count.formatted())
            LabeledContent(.dataTransferPreviewExpenses, value: plan.expenses.additions.count.formatted())
        }
        Section(.dataTransferPreviewUpdates) {
            LabeledContent(.dataTransferPreviewTrips, value: plan.trips.updates.count.formatted())
            LabeledContent(.dataTransferPreviewLocations, value: plan.locations.updates.count.formatted())
            LabeledContent(.dataTransferPreviewExpenses, value: plan.expenses.updates.count.formatted())
        }
        Section {
            LabeledContent(.dataTransferPreviewUnchanged, value: plan.unchangedCount.formatted())
            LabeledContent(.dataTransferPreviewOlder, value: plan.olderCount.formatted())
        } footer: {
            Text(.dataTransferPreviewHint)
        }
        Section {
            Button(.dataTransferImport) {
                haptics.trigger(.tap)
                viewModel.confirmImport(container: context.container)
            }
            .disabled(!plan.hasChanges)
        }
    }
}

// MARK: - Превью

#Preview("Reviewing") {
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
