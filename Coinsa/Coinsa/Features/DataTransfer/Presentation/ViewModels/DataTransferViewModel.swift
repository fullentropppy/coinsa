//
//  DataTransferViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.11.2026.
//

import Foundation
import Observation
import SwiftData

/// Управляет подготовкой файлов, подтверждением плана и повторными попытками импорта.
@MainActor
@Observable
final class DataTransferViewModel {
    // MARK: - Состояние

    var document: DataTransferDocument?
    var plan: DataTransferPlan?
    var isShowingExporter = false
    var isShowingImporter = false
    var isShowingImportPreview = false
    var isWorking = false
    var isWaitingForNotice = false
    var isShowingNotice = false
    var noticeIsError = true
    var noticeTitle: LocalizedStringResource = .dataTransferErrorTitle
    var noticeMessage: LocalizedStringResource = .dataTransferErrorFileMessage

    // MARK: - Задачи и завершение

    @ObservationIgnored private var task: Task<Void, Never>?
    @ObservationIgnored private var noticeTask: Task<Void, Never>?
    @ObservationIgnored private var resultAfterImportDismissal: ImportResult?

    // MARK: - Результат импорта

    private enum ImportResult {
        case imported
        case unchanged
    }

    // MARK: - Время переходов

    private enum Timing {
        /// Пауза перед уведомлением об успешном импорте после закрытия sheet, в миллисекундах.
        static let importCompletionDelay: Duration = .milliseconds(350)
    }

    // MARK: - Экспорт

    /// Подготавливает полный снимок; при отсутствии записей показывает сообщение вместо диалога сохранения.
    /// - Parameter container: Рабочий контейнер, из которого читаются данные без изменения истории.
    func exportData(container: ModelContainer) {
        guard !isWorking, !isWaitingForNotice else { return }
        isWorking = true
        task = Task {
            defer { isWorking = false; task = nil }
            do {
                let archive = try DataTransferRepository(container: container).snapshot()
                guard !archive.trips.isEmpty || !archive.locations.isEmpty || !archive.expenses.isEmpty else {
                    document = nil
                    showNotice(title: .dataTransferExportEmptyStateTitle, message: .dataTransferExportEmptyStateDescription)
                    return
                }
                let worker = Task.detached { try DataTransferCodec.encode(archive) }
                let data = try await withTaskCancellationHandler {
                    try await worker.value
                } onCancel: {
                    worker.cancel()
                }
                try Task.checkCancellation()
                document = DataTransferDocument(data: data)
                isShowingExporter = true
            } catch is CancellationError {
            } catch {
                showError(error, fallback: .dataTransferErrorExportMessage)
            }
        }
    }

    /// Показывает результат экспорта сразу после завершения системной операции без искусственной паузы.
    /// - Parameter result: Успешно сохраненный файл или ошибка экспорта; отмена сюда не поступает.
    func exportCompleted(_ result: Result<URL, Error>) {
        document = nil
        switch result {
        case .success:
            showNotice(title: .dataTransferExportSuccessTitle, message: .dataTransferExportSuccessMessage)
        case .failure(let error):
            showError(error, fallback: .dataTransferErrorExportMessage)
        }
    }

    // MARK: - Подготовка импорта

    /// Читает выбранный файл и открывает sheet только при наличии добавлений или обновлений.
    /// - Parameters:
    ///   - result: URL выбранного файла или ошибка системного диалога.
    ///   - container: Контейнер для сравнения файла с актуальными локальными записями.
    func importFile(_ result: Result<URL, Error>, container: ModelContainer) {
        guard !isWorking, !isWaitingForNotice else { return }
        switch result {
        case .failure(let error):
            showError(error, fallback: .dataTransferErrorReadMessage)
        case .success(let url):
            plan = nil
            isWorking = true
            task = Task {
                defer { isWorking = false; task = nil }
                do {
                    let worker = Task.detached { try DataTransferDocument.read(from: url) }
                    let archive = try await withTaskCancellationHandler {
                        try await worker.value
                    } onCancel: {
                        worker.cancel()
                    }
                    try Task.checkCancellation()
                    let preparedPlan = try DataTransferRepository(container: container).prepare(archive)
                    guard preparedPlan.hasChanges else {
                        showImportUnchangedNotice()
                        return
                    }
                    plan = preparedPlan
                    isShowingImportPreview = true
                } catch is CancellationError {
                } catch {
                    showError(error, fallback: .dataTransferErrorReadMessage)
                }
            }
        }
    }

    // MARK: - Подтверждение импорта

    /// Сохраняет подтвержденный импорт с индикатором и закрывает sheet только после успешной записи.
    /// - Parameter container: Контейнер для повторной проверки плана и атомарного локального сохранения.
    func confirmImport(container: ModelContainer) {
        guard let plan, isShowingImportPreview, !isWorking else { return }
        isWorking = true
        task = Task {
            defer { isWorking = false; task = nil }
            do {
                await Task.yield()
                try DataTransferRepository(container: container).apply(plan)
                resultAfterImportDismissal = .imported
                isShowingImportPreview = false
            } catch is CancellationError {
            } catch DataTransferError.changedSincePreview {
                do {
                    let refreshedPlan = try DataTransferRepository(container: container).prepare(plan.source)
                    guard refreshedPlan.hasChanges else {
                        resultAfterImportDismissal = .unchanged
                        isShowingImportPreview = false
                        return
                    }
                    self.plan = refreshedPlan
                    showError(DataTransferError.changedSincePreview, fallback: .dataTransferErrorSaveMessage)
                } catch {
                    showError(error, fallback: .dataTransferErrorSaveMessage)
                }
            } catch {
                showError(error, fallback: .dataTransferErrorSaveMessage)
            }
        }
    }

    /// Закрывает проверку импорта крестиком, сохраняя сводку на время анимации закрытия.
    func closeImportPreview() {
        guard !isWorking else { return }
        isShowingImportPreview = false
    }

    /// Очищает сводку после закрытия sheet; задержка применяется только к успешному сохранению.
    func importPreviewDismissed() {
        plan = nil
        let result = resultAfterImportDismissal
        resultAfterImportDismissal = nil
        switch result {
        case .imported: scheduleImportSuccessNotice()
        case .unchanged: showImportUnchangedNotice()
        case nil: break
        }
    }

    // MARK: - Отмена задач

    /// Отменяет подготовку и отложенное уведомление при уходе с основного экрана переноса.
    func cancel() {
        task?.cancel()
        noticeTask?.cancel()
    }

    // MARK: - Уведомления

    /// Показывает ошибку без закрытия сводки, чтобы сохранить возможность повторить импорт.
    /// - Parameters:
    ///   - error: Ошибка чтения, проверки или сохранения.
    ///   - fallback: Сообщение для ошибки, не относящейся к проверкам формата.
    private func showError(_ error: Error, fallback: LocalizedStringResource) {
        showNotice(title: .dataTransferErrorTitle, message: errorMessage(for: error, fallback: fallback), isError: true)
    }

    /// Возвращает локализованное описание причины отказа без технических данных из файла.
    /// - Parameters:
    ///   - error: Причина отказа операции.
    ///   - fallback: Сообщение для неизвестного типа ошибки.
    /// - Returns: Сообщение с доступным пользователю следующим действием.
    private func errorMessage(for error: Error, fallback: LocalizedStringResource) -> LocalizedStringResource {
        switch error as? DataTransferError {
        case .invalidFile: .dataTransferErrorFileMessage
        case .unsupportedVersion: .dataTransferErrorVersionMessage
        case .duplicateID: .dataTransferErrorDuplicateMessage
        case .invalidRelationships: .dataTransferErrorRelationshipsMessage
        case .invalidValues: .dataTransferErrorValuesMessage
        case .currencyConflict: .dataTransferErrorCurrencyMessage
        case .changedSincePreview: .dataTransferErrorChangedMessage
        case .localChanges: .dataTransferErrorLocalChangesMessage
        case .fileTooLarge: .dataTransferErrorSizeMessage
        case nil: fallback
        }
    }

    /// Сообщает об отсутствии изменений без открытия сводки и без записи в хранилище.
    private func showImportUnchangedNotice() {
        showNotice(title: .dataTransferImportEmptyStateTitle, message: .dataTransferImportEmptyStateDescription)
    }

    /// Откладывает только сообщение об успешном импорте после завершения закрытия sheet.
    private func scheduleImportSuccessNotice() {
        guard !isWaitingForNotice else { return }
        isWaitingForNotice = true
        noticeTask = Task {
            defer { isWaitingForNotice = false; noticeTask = nil }
            do {
                try await Task.sleep(for: Timing.importCompletionDelay)
                showNotice(title: .dataTransferSuccessTitle, message: .dataTransferSuccessMessage)
            } catch is CancellationError {
            } catch {
                showNotice(title: .dataTransferSuccessTitle, message: .dataTransferSuccessMessage)
            }
        }
    }

    /// Обновляет содержимое уведомления до его показа на активном экране.
    /// - Parameters:
    ///   - title: Заголовок уведомления.
    ///   - message: Текст уведомления.
    ///   - isError: Признак ошибочного результата.
    private func showNotice(title: LocalizedStringResource, message: LocalizedStringResource, isError: Bool = false) {
        noticeTitle = title
        noticeMessage = message
        noticeIsError = isError
        isShowingNotice = true
    }
}
